defmodule CoursePlanner.OfferedCourses do
  @moduledoc false

  alias CoursePlanner.{OfferedCourse, Repo, Attendance, AttendanceHelper}
  alias Ecto.{Multi, DateTime}
  import Ecto.{Query}

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

    for oc1 <- offered_courses, oc2 <- offered_courses do
      student_ids1 = Enum.map(oc1.students, &(&1.id))
      student_ids2 = Enum.map(oc2.students, &(&1.id))
      {oc1.id, oc2.id, count_intersection(student_ids1, student_ids2)}
    end
    |> Enum.group_by(fn {oc1, _, _} -> oc1 end, fn {_, oc2, students} -> {oc2, students} end)
  end

  def query_by_term_id(term_id) do
    from oc in OfferedCourse, where: oc.term_id == ^term_id
  end

  def count_intersection(students1, students2) do
    Enum.count(students1, &(&1 in students2))
  end
end
