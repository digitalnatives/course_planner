defmodule CoursePlanner.CourseMatrixView do
  @moduledoc false
  use CoursePlanner.Web, :view

  def course_name(offered_courses, id) do
    offered_courses[id].course.name
  end

  def total_students(offered_courses, id) do
    length(offered_courses[id].students)
  end
end
