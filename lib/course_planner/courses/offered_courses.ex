defmodule CoursePlanner.Courses.OfferedCourses do
  @moduledoc false

  alias CoursePlanner.{Courses.OfferedCourse, Repo, Attendances, Notifications.Notifier,
                       Notifications}
  import Ecto.Query

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

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

  def load_offered_course_for_edit(id) do
    offered_course =
      OfferedCourse
      |> Repo.get!(id)
      |> Repo.preload([:term, :course, :students, :teachers])
    changeset = OfferedCourse.changeset(offered_course)

    {:ok, offered_course, changeset}
  end
end
