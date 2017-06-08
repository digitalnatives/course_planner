defmodule CoursePlanner.AttendanceTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Attendance}
  import CoursePlanner.Factory

  @valid_class_attrs %{offered_course: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 15, min: 0, sec: 0}}
  @valid_attrs %{student_id: nil, class_id: nil, attendance_type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    student = insert(:user, %{role: "Student"})
    offered_course = insert(:offered_course, %{students: [student]})
    class = insert(:class, %{@valid_class_attrs | offered_course: offered_course})

    changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Attendance.changeset(%Attendance{}, @invalid_attrs)
    refute changeset.valid?
  end
end
