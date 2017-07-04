defmodule CoursePlanner.AttendanceView do
  use CoursePlanner.Web, :view

  def get_teacher_display_name(offered_course_teachers) do
    offered_course_teachers
    |> Enum.map(fn(teacher) -> Enum.join([teacher.name, teacher.family_name], " ") end)
    |> Enum.join(", ")
  end

  def get_student_display_name(student) do
    Enum.join([student.name, student.family_name], " ")
  end
end
