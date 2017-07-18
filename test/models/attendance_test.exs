defmodule CoursePlanner.AttendanceTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Attendance}
  import CoursePlanner.Factory

  @valid_class_attrs %{offered_course: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 15, min: 0, sec: 0}}
  @valid_attrs %{student_id: nil, class_id: nil, attendance_type: "some content", comment: ""}
  @invalid_attrs %{}

  setup do
    insert(:system_variable, key: "ATTENDANCE_DESCRIPTIONS", value: "sick_leave, informed beforehand, withdraw, canceled", type: "list")

    student = insert(:user, %{role: "Student"})
    offered_course = insert(:offered_course, %{students: [student]})
    class = insert(:class, %{@valid_class_attrs | offered_course: offered_course})

    {:ok, %{student: student, class: class}}
  end

  test "changeset with valid attributes", %{student: student, class: class} do
    changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Attendance.changeset(%Attendance{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "attendance comment" do
    test "passes when comment is empty", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: ""})
      assert changeset.valid?
    end

    test "passes when comment is nil", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: nil})
      assert changeset.valid?
    end

    test "passes when comment is among valid options", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: "sick_leave"})
      assert changeset.valid?
    end

    test "fails when comment is not among valid options", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: "random"})
      refute changeset.valid?
    end

    test "fails when comment has trailing space", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: "sick_leave     "})
      refute changeset.valid?
    end

    test "fails when comment has leading space", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: "      sick_leave"})
      refute changeset.valid?
    end

    test "fails when comment has leading space and trailing space", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: "      sick_leave       "})
      refute changeset.valid?
    end

    test "passes when setting and comment both have value with space in between", %{student: student, class: class} do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id, comment: "informed beforehand"})
      assert changeset.valid?
    end
  end
end
