defmodule CoursePlanner.Courses.OfferedCourses do
  @moduledoc false

  alias CoursePlanner.{Courses.OfferedCourse, Repo, Attendances, Notifications.Notifier,
                       Notifications, Accounts.Students, Accounts.Teachers}
  import Ecto.Query
  alias Ecto.Changeset

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

  def insert(params) do

    student_ids = Map.get(params, "student_ids", [])
    students = Repo.all(from s in Students.query(), where: s.id in ^student_ids)

    teacher_ids = Map.get(params, "teacher_ids", [])
    teachers = Repo.all(from s in Teachers.query(), where: s.id in ^teacher_ids)

    %OfferedCourse{}
    |> OfferedCourse.changeset(params)
    |> Changeset.put_assoc(:students, students)
    |> Changeset.put_assoc(:teachers, teachers)
    |> Repo.insert()
  end

  def new do
    OfferedCourse.changeset(%OfferedCourse{})
  end

  def get(id, preload \\ []) do
    case Repo.get(OfferedCourse, id) do
      nil -> {:error, :not_found}
      course -> {:ok, Repo.preload(course, preload)}
    end
  end

  def edit(id) do
    case get(id, [:term, :course, :students, :teachers]) do
      {:ok, offered_course} -> {:ok, offered_course, OfferedCourse.changeset(offered_course)}
      error -> error
    end
  end

  def update(id, params) do
    student_ids = Map.get(params, "student_ids", [])
    students = Repo.all(from s in Students.query(), where: s.id in ^student_ids)

    teacher_ids = Map.get(params, "teacher_ids", [])
    teachers = Repo.all(from s in Teachers.query(), where: s.id in ^teacher_ids)

    case get(id, [:term, :course, :students, :teachers]) do
      {:ok, offered_course} -> offered_course
        |> OfferedCourse.changeset(params)
        |> Changeset.put_assoc(:students, students)
        |> Changeset.put_assoc(:teachers, teachers)
        |> Repo.update()
        |> format_error(offered_course, students)
      error -> error
    end
  end

  def update_syllabus(offered_course, syllabus) do
    offered_course
    |> OfferedCourse.changeset(%{syllabus: syllabus})
    |> Repo.update()
    |> format_error(offered_course, nil)
  end

  defp format_error({:ok, offered_course}, _, students), do: {:ok, offered_course, students}
  defp format_error({:error, changeset}, offered_course, students),
    do: {:error, offered_course, students, changeset}

  def delete(id) do
    case get(id) do
      nil -> {:error, :not_found}
      {:ok, offered_course} -> Repo.delete(offered_course)
    end
  end

  def find_by_term_id(term_id) do
    term_id
    |> query_by_term_id()
    |> select([oc], {oc.id, oc})
    |> preload([:course, :students])
    |> Repo.all()
    |> Enum.into(%{})
  end

  def student_matrix(term_id) do
    offered_courses =
      term_id
      |> query_by_term_id()
      |> Repo.all()
      |> Repo.preload([:students])

    course_intersections =
      for oc1 <- offered_courses, oc2 <- offered_courses do
        student_ids1 = Enum.map(oc1.students, &(&1.id))
        student_ids2 = Enum.map(oc2.students, &(&1.id))
        {oc1.id, oc2.id, count_intersection(student_ids1, student_ids2)}
      end

    Enum.group_by(
      course_intersections,
      fn {oc1, _, _} -> oc1 end,
      fn {_, oc2, students} -> {oc2, students} end)
  end

  def query_by_term_id(term_id) do
    from oc in OfferedCourse, where: oc.term_id == ^term_id
  end

  def count_intersection(students1, students2) do
    Enum.count(students1, &(&1 in students2))
  end

  def get_subscribed_users(offered_courses) do
    offered_courses
    |> Enum.flat_map(fn(offered_course) ->
      Map.get(offered_course, :teachers) ++ Map.get(offered_course, :students)
    end)
    |> Enum.uniq_by(fn %{id: id} -> id end)
  end

  def with_pending_attendances(date \\ Timex.now()) do
   Repo.all(from oc in OfferedCourse,
     join: c in assoc(oc,  :classes),
     join: a in assoc(c,  :attendances),
     preload: [:teachers, :course, :term, classes: {c, attendances: a}],
     where: c.date < ^date and a.attendance_type == "Not filled")
  end

  def create_pending_attendance_notification_map(notifiable_users) do
    notifiable_ids = Enum.map(notifiable_users, &(&1.id))
    for oc <- with_pending_attendances(), t <- oc.teachers, t.id in notifiable_ids do
      %{
        user: t,
        type: :attendance_missing,
        path: Attendances.get_offered_course_fill_attendance_path(oc.id),
        data: %{offered_course_name: "#{oc.term.name}-#{oc.course.name}"}
      }
    end
  end

  def create_missing_attendance_notifications(notifiable_users) do
    notifiable_users
    |> create_pending_attendance_notification_map()
    |> Enum.each(fn(email_data) ->
         email_data
         |> Notifications.create_simple_notification()
         |> @notifier.notify_later()
       end)
  end
end
