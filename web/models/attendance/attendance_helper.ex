defmodule CoursePlanner.AttendanceHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, OfferedCourse}

  def get_all_offered_courses do
    Repo.all(from OfferedCourse,
      preload: [:term, :course, :teachers])
  end

  def get_all_teacher_offered_courses(teacher_id) do
    Repo.all(from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      preload: [:term, :course, teachers: t],
      where: t.id == ^teacher_id)
  end

  def get_all_student_offered_courses(student_id) do
    Repo.all(from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      preload: [:term, :course, :teachers, students: s],
      where: s.id == ^student_id)
  end
end
