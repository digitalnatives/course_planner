defmodule CoursePlanner.StudentView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.Students

  def student_courses(student) do
    Students.courses(student)
  end
end
