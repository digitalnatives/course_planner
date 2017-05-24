defmodule CoursePlanner.AttendanceTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Attendance}
  import CoursePlanner.Factory

  @valid_class_attrs %{offered_course_id: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 15, min: 0, sec: 0}, status: "Planned"}
  @valid_attrs %{student_id: nil, class_id: nil, attendance_type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    course = insert(:course)
    term1 = insert(:term, %{
                            start_date: %Ecto.Date{day: 1, month: 1, year: 2017},
                            end_date: %Ecto.Date{day: 1, month: 6, year: 2017},
                            courses: [course]
                           })
    student = insert(:user, %{role: "Student"})
    offered_course = insert(:offered_course, %{term: term1, course: course, students: [student]})
    class = insert(:class, %{@valid_class_attrs | offered_course_id: offered_course.id, status: "Active"})

    changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: student.id, class_id: class.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Attendance.changeset(%Attendance{}, @invalid_attrs)
    refute changeset.valid?
  end
end
