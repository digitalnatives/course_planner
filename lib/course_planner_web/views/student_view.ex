defmodule CoursePlannerWeb.StudentView do
  @moduledoc false
  use CoursePlannerWeb, :view

  alias CoursePlanner.Accounts.Students

  def student_courses(student) do
    Students.courses(student)
  end

  def page_title do
    "Students"
  end
end
