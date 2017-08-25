defmodule CoursePlanner.OfferedCoursesTest do
  use CoursePlannerWeb.ModelCase
  import CoursePlanner.Factory
  alias CoursePlanner.OfferedCourses

  describe "student_matrix/1" do
    test "should return the amount of common students by pair of courses" do
      term = insert(:term)

      [student1, student2, student3] = insert_list(3, :student)

      course1 = insert(:offered_course, %{term: term, students: [student1, student2]})
      course2 = insert(:offered_course, %{term: term, students: [student1]})
      course3 = insert(:offered_course, %{term: term, students: [student3]})

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
  end

  describe "get_subscibed_users/1" do
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

  describe "find_all_by_user/1" do
    test "coordinators should see all offered courses" do
      user = insert(:coordinator)
      insert_list(2, :offered_course)

      courses = OfferedCourses.find_all_by_user(user)

      assert length(courses) == 2
    end

    test "teachers should see the offered courses they are assigned to" do
      user = insert(:teacher)
      user_course = insert(:offered_course, teachers: [user])
      insert(:offered_course)

      courses = OfferedCourses.find_all_by_user(user)

      assert length(courses) == 1
      assert List.first(courses).id == user_course.id
    end

    test "students should see the offered courses they are assigned to" do
      user = insert(:student)
      user_course = insert(:offered_course, students: [user])
      insert(:offered_course)

      courses = OfferedCourses.find_all_by_user(user)

      assert length(courses) == 1
      assert List.first(courses).id == user_course.id
    end
  end

  describe "find_by_term_id/1" do
    test "find a valid term" do
      offered_course = insert(:offered_course) |> Repo.preload([:students])

      result = OfferedCourses.find_by_term_id(offered_course.term.id)
      assert result[offered_course.id].id == offered_course.id

    end
  end
end
