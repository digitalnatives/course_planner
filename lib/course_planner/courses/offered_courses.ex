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

  def find_all_by_user(%{role: "Coordinator"}) do
    Repo.all(OfferedCourse)
  end
  def find_all_by_user(%{role: "Teacher", id: user_id}) do
    Repo.all(
      from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      where: t.id == ^user_id
    )
  end
  def find_all_by_user(%{role: "Student", id: user_id}) do
    Repo.all(
      from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      where: s.id == ^user_id
    )
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
      with_pending_attendances()
      |> Enum.flat_map(fn(offered_course) ->
        offered_course.teachers
        |> Enum.filter(fn(teacher) ->
             Enum.any?(notifiable_users, &(&1.id == teacher.id))
           end)
        |> Enum.map(fn(teacher) ->
           %{
              user: teacher,
              type: :attendance_missing,
              path: Attendances.get_offered_course_fill_attendance_path(offered_course.id),
              data: %{offered_course_name:
                      "#{offered_course.term.name}-#{offered_course.course.name}"}
            }
        end)
      end)
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
