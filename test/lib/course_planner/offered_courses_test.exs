defmodule CoursePlanner.OfferedCoursesTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Course, OfferedCourse, OfferedCourses, Repo, Students, Terms}
  alias Ecto.Changeset
  import CoursePlanner.Factory

  defp create_term do
    Terms.create(
      %{
        name: "Fall",
        start_date: "2017-01-01",
        end_date: "2017-06-01",
        minimum_teaching_days: 5,
        status: "Active"
      })
  end

  defp create_student(name) do
    Students.new(%{name: name, email: "#{name}@example.com"}, "token")
  end

  defp create_course(name, term, students) do
    course =
      %Course{}
      |> Course.changeset(
        %{
          name: name,
          description: "Description"
        })
      |> Repo.insert!

    %OfferedCourse{}
      |> OfferedCourse.changeset(%{term_id: term.id, course_id: course.id, number_of_sessions: 1, syllabus: "some content"})
      |> Changeset.put_assoc(:students, students)
      |> Repo.insert
  end

  test "should return the amount of common students by pair of courses" do
    {:ok, term} = create_term()

    {:ok, student1} = create_student("student1")
    {:ok, student2} = create_student("student2")
    {:ok, student3} = create_student("student3")

    {:ok, course1} = create_course("Course1", term, [student1, student2])
    {:ok, course2} = create_course("Course2", term, [student1])
    {:ok, course3} = create_course("Course3", term, [student3])

    students = OfferedCourses.student_matrix(term.id)

    assert {course1.id, 2} in Map.get(students, course1.id)
    assert {course2.id, 1} in Map.get(students, course1.id)
    assert {course3.id, 0} in Map.get(students, course1.id)
    assert {course1.id, 1} in Map.get(students, course2.id)
    assert {course2.id, 1} in Map.get(students, course2.id)
    assert {course3.id, 0} in Map.get(students, course2.id)
    assert {course1.id, 0} in Map.get(students, course3.id)
    assert {course2.id, 0} in Map.get(students, course3.id)
    assert {course3.id, 1} in Map.get(students, course3.id)
  end

  test "should return the subscribed users of offered_courses" do
    students = insert_list(3, :student)
    teachers = insert_list(2, :teacher)
    insert(:coordinator)

    offered_course1 = insert(:offered_course, students: students, teachers: teachers)
    offered_course2 = insert(:offered_course, students: students, teachers: teachers)

    offered_courses_users = OfferedCourses.get_subscribed_users([offered_course1, offered_course2])
    assert length(offered_courses_users) == 5
  end
end
