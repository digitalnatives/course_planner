defmodule CoursePlanner.AttendanceViewTest do
  use CoursePlannerWeb.ConnCase, async: true

  alias CoursePlannerWeb.AttendanceView
  import CoursePlanner.Factory

  test "get_teacher_display_name/1" do
    [teacher1, teacher2] =
      [
        insert(:teacher, name: "teacher-1"),
        insert(:teacher, name: "teacher-2")
      ]
    assert "#{teacher1.name}, #{teacher2.name}" == AttendanceView.get_teacher_display_name([teacher1, teacher2])
  end
end
