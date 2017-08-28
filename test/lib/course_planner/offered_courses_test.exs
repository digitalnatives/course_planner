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

  describe "get_offered_courses_with_pending_attendances" do
    test "when there is no offered_course" do
      assert [] == OfferedCourses.get_offered_courses_with_pending_attendances()
    end

    test "when there is no class for an offered_course" do
      insert(:offered_course)
      assert [] == OfferedCourses.get_offered_courses_with_pending_attendances()
    end

    test "when there is no attendance for class" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      class = insert(:class, date: Timex.now())
      insert(:offered_course, classes: [class], students: students, teachers: [teacher])

      requested_current_date =  Timex.shift(Timex.now(), days: 2)
      assert [] == OfferedCourses.get_offered_courses_with_pending_attendances(requested_current_date)
    end

    test "when the class is in future" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      class = insert(:class, date: Timex.shift(Timex.now(), days: 2))
      Enum.each(students, fn(student) ->
        insert(:attendance, student: student, class: class, attendance_type: "Not filled")
      end)
      insert(:offered_course, classes: [class], students: students, teachers: [teacher])

      assert [] == OfferedCourses.get_offered_courses_with_pending_attendances()
    end

    test "when all attendances of the class are filled for an offered_course" do
     students = insert_list(3, :student)
     teacher = insert(:teacher)
     class = insert(:class, date: Timex.now())
     Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class, attendance_type: "Present")
     end)
     insert(:offered_course, classes: [class], students: students, teachers: [teacher])

     requested_current_date =  Timex.shift(Timex.now(), days: 2)
     assert [] == OfferedCourses.get_offered_courses_with_pending_attendances(requested_current_date)
    end

    test "when there is missing attendances for one class of an offered_course" do
     students = insert_list(3, :student)
     teacher = insert(:teacher)
     class = insert(:class, date: Timex.shift(Timex.now(), days: -2))
     Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class, attendance_type: "Not filled")
     end)
     offered_course =
       insert(:offered_course, classes: [class], students: students, teachers: [teacher])

     requested_current_date =  Timex.now()
     [not_filled_offered_course] = OfferedCourses.get_offered_courses_with_pending_attendances(requested_current_date)
     assert offered_course.id == not_filled_offered_course.id
    end

    test "when there is missing attendances for some classes of an offered_course" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      [class1, class2, class3] = insert_list(3, :class, date: Timex.now())

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
      end)
      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class2, attendance_type: "Present")
      end)

      [student1, student2, student3] = students
      insert(:attendance, student: student1, class: class3, attendance_type: "Present")
      insert(:attendance, student: student2, class: class3, attendance_type: "Not filled")
      insert(:attendance, student: student3, class: class3, attendance_type: "Present")

      offered_course =
       insert(:offered_course, classes: [class1, class2, class3], students: students, teachers: [teacher])

      requested_current_date =  Timex.shift(Timex.now(), days: 2)
      [not_filled_offered_course] = OfferedCourses.get_offered_courses_with_pending_attendances(requested_current_date)

      not_filled_classes =
        not_filled_offered_course.classes
        |> Enum.map(&(&1.id))
        |> Enum.sort(&(&1 < &2))
      expected_classes =
        [class1.id, class3.id]
        |> Enum.sort(&(&1 < &2))

      assert offered_course.id == not_filled_offered_course.id
      assert expected_classes == not_filled_classes
    end

    test "when there is missing attendances for some classes of multiple offered_courses" do
     students = insert_list(3, :student)
     teacher = insert(:teacher)
     [class1, class2, class3] = insert_list(3, :class, date: Timex.now())

     Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
     end)
     Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class2, attendance_type: "Present")
     end)

     [student1, student2, student3] = students
     insert(:attendance, student: student1, class: class3, attendance_type: "Present")
     insert(:attendance, student: student2, class: class3, attendance_type: "Not filled")
     insert(:attendance, student: student3, class: class3, attendance_type: "Present")

     offered_course1 =
       insert(:offered_course, classes: [class1], students: students, teachers: [teacher])
     insert(:offered_course, classes: [class2], students: students, teachers: [teacher])
     offered_course3 =
       insert(:offered_course, classes: [class3], students: students, teachers: [teacher])

     requested_current_date =  Timex.shift(Timex.now(), days: 2)
     not_filled_offered_courses =
       OfferedCourses.get_offered_courses_with_pending_attendances(requested_current_date)
       |> Enum.map(&(&1.id))
       |> Enum.sort(&(&1 < &2))
     expected_result =
       [offered_course1.id, offered_course3.id]
       |> Enum.sort(&(&1 < &2))

     assert expected_result == not_filled_offered_courses
    end
  end
end
