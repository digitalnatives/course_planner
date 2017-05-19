defmodule CoursePlanner.AttendanceTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Attendance, Factory}

  @valid_attrs %{student_id: nil, class_id: nil, attendance_type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    course = Factory.create_course("english")
    term1 = Factory.create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    student = Factory.create_student("john", "john@smith.com")
    offered_course = Factory.create_offered_course(term1, course, [student])
    class = Factory.create_class(offered_course)

    changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Attendance.changeset(%Attendance{}, @invalid_attrs)
    refute changeset.valid?
  end
end
