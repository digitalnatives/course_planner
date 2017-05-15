defmodule CoursePlanner.StudentView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.Teachers

  def student_courses(student) do
    Students.courses(student)
  end
end
