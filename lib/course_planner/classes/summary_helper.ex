defmodule CoursePlanner.SummaryHelper do
  @moduledoc """
    Provides helper functions for the summary page
  """
  use CoursePlannerWeb, :model

  alias CoursePlanner.{Repo, Terms.Term, Courses.OfferedCourse, Tasks.Task}
  alias Ecto.DateTime

  def get_term_offered_course_for_user(%{id: user_id, role: role}, time \\ Timex.now()) do
    case role do
      "Student" -> get_student_registered_data(user_id, time)
      "Teacher" -> get_teacher_registered_data(user_id, time)
      "Coordinator" -> get_all_terms_and_offered_courses(time)
      "Volunteer" -> get_all_terms_and_offered_courses(time)
      _           -> extract_data_from_offered_courses([])
    end
  end

  def get_all_terms_and_offered_courses(time) do
    offered_courses =
      Repo.all(from oc in OfferedCourse,
      join: t in assoc(oc, :term),
      preload: [:course, :classes, term: t],
      where: t.end_date >= ^time)

    terms =
      Repo.all(from t in Term,
      where: t.end_date >= ^time)

    %{terms: terms, offered_courses: offered_courses}
  end

  def get_student_registered_data(student_id, time) do
    offered_courses =
      Repo.all(from oc in OfferedCourse,
        join: s in assoc(oc, :students),
        join: t in assoc(oc, :term),
        preload: [:course, :classes, term: t, students: s],
        where: s.id == ^student_id and t.end_date >= ^time)

    extract_data_from_offered_courses(offered_courses)
  end

  def get_teacher_registered_data(teacher_id, time) do
    offered_courses =
      Repo.all(from oc in OfferedCourse,
        join: t in assoc(oc, :teachers),
        join: te in assoc(oc, :term),
        preload: [:term, :course, :classes, term: te, teachers: t],
        where: t.id == ^teacher_id and te.end_date >= ^time)

    extract_data_from_offered_courses(offered_courses)
  end

  defp extract_data_from_offered_courses(offered_courses)
    when is_list(offered_courses) and length(offered_courses) > 0 do
    terms  =
      offered_courses
      |> Enum.map(&(&1.term))
      |> Enum.uniq()

    %{terms: terms, offered_courses: offered_courses}
  end
  defp extract_data_from_offered_courses(_offered_courses), do: %{terms: [], offered_courses: []}

  def get_next_class(offered_courses, time \\ Timex.now())
  def get_next_class(offered_courses, time)
    when is_list(offered_courses) and length(offered_courses) > 0 do
     offered_courses
       |> Enum.flat_map(&(&1.classes))
       |> Enum.filter(fn(class) ->
         class_starting_at_datetime =
           class.date
           |> DateTime.from_date_and_time(class.starting_at)
           |> Timex.Ecto.DateTime.cast!

         Timex.compare(class_starting_at_datetime, time) >= 0
       end)
       |> Enum.sort(fn(class1, class2) ->
          class1_datetime = DateTime.from_date_and_time(class1.date, class1.starting_at)
          class2_datetime = DateTime.from_date_and_time(class2.date, class2.starting_at)
          DateTime.compare(class1_datetime, class2_datetime) != :gt

          end)
       |> List.first
  end
  def get_next_class(_offered_courses, _time), do: nil

  def get_next_task(user, time \\ Timex.now())
  def get_next_task(%{id: user_id, role: "Volunteer"}, time) do
    Repo.one(from t in Task,
      join: v in assoc(t, :volunteers),
      preload: [volunteers: v],
      where: v.id == ^user_id and t.start_time >= ^time,
      order_by: [:start_time],
      limit: 1)
  end
  def get_next_task(_user, _time), do: nil
end
