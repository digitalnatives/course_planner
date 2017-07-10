defmodule CoursePlanner.TeacherView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.Teachers

  def teacher_courses(teacher_id) do
    Teachers.courses(teacher_id)
  end

  def page_title do
    "Teachers"
  end
end
