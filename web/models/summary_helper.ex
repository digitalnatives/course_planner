defmodule CoursePlanner.SummaryHelper do
  @moduledoc """
    Provides helper functions for the summary page
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Terms.Term, OfferedCourse}

  def get_term_offered_course_for_user(user_id, user_role) do
    case user_role do
      "Student" -> get_student_registered_data(user_id)
      "Teacher" -> get_teacher_registered_data(user_id)
      "Coordinator" -> get_all_terms_and_offered_courses()
      "Volunteer" -> get_all_terms_and_offered_courses()
      _           -> extract_data_from_offered_courses([])
    end
  end

  def get_all_terms_and_offered_courses do
    current_time = Timex.now()

    offered_courses =
      Repo.all(from oc in OfferedCourse,
      join: t in assoc(oc, :term),
      preload: [:course, :classes, term: t],
      where: t.end_date >= ^current_time)

    terms =
      Repo.all(from t in Term,
      where: t.end_date >= ^current_time)

    %{terms: terms, offered_courses: offered_courses}
  end

  def get_student_registered_data(student_id) do
    current_time = Timex.now()

    offered_courses =
      Repo.all(from oc in OfferedCourse,
        join: s in assoc(oc, :students),
        join: t in assoc(oc, :term),
        preload: [:course, :classes, term: t, students: s],
        where: s.id == ^student_id and t.end_date >= ^current_time)

    extract_data_from_offered_courses(offered_courses)
  end

  def get_teacher_registered_data(teacher_id) do
    current_time = Timex.now()

    offered_courses =
      Repo.all(from oc in OfferedCourse,
        join: t in assoc(oc, :teachers),
        join: te in assoc(oc, :term),
        preload: [:term, :course, :classes, term: te, teachers: t],
        where: t.id == ^teacher_id and te.end_date >= ^current_time)

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
end
