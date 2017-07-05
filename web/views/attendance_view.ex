defmodule CoursePlanner.AttendanceView do
  use CoursePlanner.Web, :view

  def get_teacher_display_name(offered_course_teachers) do
    Enum.reduce(offered_course_teachers, "", fn(teacher, out) ->
              Enum.join([out, teacher.name, teacher.family_name], " ") end)
  end

  def get_student_display_name(student) do
    Enum.join([student.name, student.family_name], " ")
  end

  def page_title do
    "Attendances"
  end
end
