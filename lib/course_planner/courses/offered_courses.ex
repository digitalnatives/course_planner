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
    offered_courses = Repo.all(from oc in OfferedCourse,
      join: c in assoc(oc, :course),
      preload: [:students, course: c],
      order_by: [asc: c.name],
      where: oc.term_id == ^term_id)

    offered_courses
    |> Enum.map(fn(main_offered_course) ->
         {main_offered_course.id, get_intersection(main_offered_course, offered_courses)}
       end)
  end

  def query_by_term_id(term_id) do
    from oc in OfferedCourse, where: oc.term_id == ^term_id
  end

  def get_intersection(main_offered_course, all_offered_courses) do
    all_offered_courses
    |> Enum.map(fn(target_offered_course) ->
      student_ids1 = Enum.map(main_offered_course.students, &("#{&1.name} #{&1.family_name}"))
      student_ids2 = Enum.map(target_offered_course.students, &("#{&1.name} #{&1.family_name}"))
      intersection = Enum.filter(student_ids1, &(&1 in student_ids2))
      {target_offered_course.id, length(intersection), intersection}
    end)
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
