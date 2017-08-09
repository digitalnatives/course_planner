defmodule CoursePlanner.SummaryHelper do
  @moduledoc """
    Provides helper functions for the summary page
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Terms.Term, OfferedCourse, Tasks.Task}

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

  def get_next_class(offered_courses)
    when is_list(offered_courses) and length(offered_courses) > 0 do
     offered_courses
       |> Enum.flat_map(&(&1.classes))
       |> Enum.sort(&(&1.date <= &2.date and &1.starting_at <= &2.starting_at))
       |> List.first
  end
  def get_next_class(_offered_courses), do: nil

  def get_next_task(%{id: user_id, role: "Volunteer"}, time) do
    Repo.all(from t in Task,
      join: v in assoc(t, :volunteers),
      preload: [volunteers: v],
      where: v.id == ^user_id and t.finish_time >= ^time)
    |> Enum.sort(&(&1.start_time <= &2.start_time))
    |> List.first
  end
  def get_next_task(%{id: _user_id, role: _role}, _time), do: nil
end
