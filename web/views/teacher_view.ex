defmodule CoursePlanner.TeacherView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.{Repo, Teachers}

  def teacher_courses(teacher_id) do
    Teachers.courses(teacher_id)
  end
end
