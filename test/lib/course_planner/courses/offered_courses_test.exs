defmodule CoursePlanner.OfferedCoursesTest do
  use CoursePlannerWeb.ModelCase

  import CoursePlanner.Factory
  alias CoursePlanner.{Courses.OfferedCourses, Attendances, Notifications.Notification}

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

  describe "with_pending_attendances" do
    test "when there is no offered_course" do
      assert [] == OfferedCourses.with_pending_attendances()
    end

    test "when there is no class for an offered_course" do
      insert(:offered_course)
      assert [] == OfferedCourses.with_pending_attendances()
    end

    test "when there is no attendance for class" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      class = insert(:class, date: Timex.now())
      insert(:offered_course, classes: [class], students: students, teachers: [teacher])

      requested_current_date =  Timex.shift(Timex.now(), days: 2)
      assert [] == OfferedCourses.with_pending_attendances(requested_current_date)
    end

    test "when the class is in future" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      class = insert(:class, date: Timex.shift(Timex.now(), days: 2))
      Enum.each(students, fn(student) ->
        insert(:attendance, student: student, class: class, attendance_type: "Not filled")
      end)
      insert(:offered_course, classes: [class], students: students, teachers: [teacher])

      assert [] == OfferedCourses.with_pending_attendances()
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
     assert [] == OfferedCourses.with_pending_attendances(requested_current_date)
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
     [not_filled_offered_course] = OfferedCourses.with_pending_attendances(requested_current_date)
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

      insert(:offered_course, classes: [class1, class2, class3], students: students, teachers: [teacher])

      requested_current_date =  Timex.shift(Timex.now(), days: 2)
      [not_filled_offered_courses] = OfferedCourses.with_pending_attendances(requested_current_date)

      not_filled_classes = Enum.map(not_filled_offered_courses.classes, &(&1.id))

      assert class1.id in not_filled_classes
      assert class3.id in not_filled_classes
      refute class2.id in not_filled_classes
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

     insert(:offered_course, classes: [class1], students: students, teachers: [teacher])
     insert(:offered_course, classes: [class2], students: students, teachers: [teacher])
     insert(:offered_course, classes: [class3], students: students, teachers: [teacher])

     requested_current_date =  Timex.shift(Timex.now(), days: 2)

     not_filled_classes =
       requested_current_date
       |> OfferedCourses.with_pending_attendances()
       |> Enum.flat_map(&(&1.classes))
       |> Enum.map(&(&1.id))

     assert class1.id in not_filled_classes
     assert class3.id in not_filled_classes
     refute class2.id in not_filled_classes
    end
  end

  describe "test creation of missing attendance notifications" do
    test "when there is no offered_course" do
      teacher = insert(:teacher)
      OfferedCourses.create_missing_attendance_notifications([teacher])
      assert [] == Repo.all(Notification)
    end

    test "when there is no classes" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)

      insert(:offered_course, classes: [], students: students, teachers: [teacher])
      OfferedCourses.create_missing_attendance_notifications([teacher])
      assert [] == Repo.all(Notification)
    end

    test "when there is no attendances" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      [class1, class2] = insert_list(2, :class, date: Timex.shift(Timex.now(), days: -2))

      insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher])
      OfferedCourses.create_missing_attendance_notifications([teacher])
      assert [] == Repo.all(Notification)
    end

    test "when there is no missing attendance" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      [class1, class2] = insert_list(2, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Present")
       insert(:attendance, student: student, class: class2, attendance_type: "Present")
      end)

      insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher])
      OfferedCourses.create_missing_attendance_notifications([teacher])
      assert [] == Repo.all(Notification)
    end

    test "when there is one offered_course with one teacher have missing attendance" do
      students = insert_list(3, :student)
      teacher = insert(:teacher)
      [class1, class2] = insert_list(2, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class2, attendance_type: "Not filled")
      end)

      offered_course = insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher])

      OfferedCourses.create_missing_attendance_notifications([%{teacher | updated_at: NaiveDateTime.utc_now}])
      [notification] =
        Notification
        |> Repo.all()
        |> Repo.preload(:user)
        |> Enum.sort(&(&1.user.id <= &2.user.id))

      assert notification.user == teacher
      assert notification.type == "attendance_missing"
      assert notification.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course.id)
    end

    test "when there is one offered_course with multiple teacher have missing attendance" do
      students = insert_list(3, :student)
      [teacher1, teacher2] = insert_list(2, :teacher)
      [class1, class2] = insert_list(2, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class2, attendance_type: "Not filled")
      end)

      offered_course = insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher1, teacher2])

      OfferedCourses.create_missing_attendance_notifications([teacher1, teacher2])
      [notification1, notification2] =
        Notification
        |> Repo.all()
        |> Repo.preload(:user)
        |> Enum.sort(&(&1.user.id <= &2.user.id))

      assert notification1.user == teacher1
      assert notification1.type == "attendance_missing"
      assert notification1.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course.id)

      assert notification2.user == teacher2
      assert notification2.type == "attendance_missing"
      assert notification2.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course.id)
    end

    test "when multiple offered_course with multiple teacher have missing attendance" do
      students = insert_list(3, :student)
      [teacher1, teacher2, teacher3] = insert_list(3, :teacher)
      [class1, class2, class3] = insert_list(3, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class2, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class3, attendance_type: "Not filled")
      end)

      offered_course1 = insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher1])
      offered_course2 = insert(:offered_course, classes: [class3], students: students, teachers: [teacher2, teacher3])

      OfferedCourses.create_missing_attendance_notifications([teacher1, teacher2, teacher3])
      [notification1, notification2, notification3] =
        Notification
        |> Repo.all()
        |> Repo.preload(:user)
        |> Enum.sort(&(&1.user.id <= &2.user.id))

      assert notification1.user == teacher1
      assert notification1.type == "attendance_missing"
      assert notification1.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course1.id)

      assert notification2.user == teacher2
      assert notification2.type == "attendance_missing"
      assert notification2.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course2.id)

      assert notification3.user == teacher3
      assert notification3.type == "attendance_missing"
      assert notification3.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course2.id)
    end

    test "when there is one offered_course with multiple teacher have missing attendance but no teacher should get notification" do
      students = insert_list(3, :student)
      [teacher1, teacher2] = insert_list(2, :teacher)
      [class1, class2] = insert_list(2, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class2, attendance_type: "Not filled")
      end)

      insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher1, teacher2])

      OfferedCourses.create_missing_attendance_notifications([])
      assert [] == Repo.all(Notification)
    end

    test "when there is one offered_course with multiple teacher have missing attendance but only one teacher should get notification" do
      students = insert_list(3, :student)
      [teacher1, teacher2, teacher3] = insert_list(3, :teacher)
      [class1, class2] = insert_list(2, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class2, attendance_type: "Not filled")
      end)

      offered_course = insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher1, teacher2, teacher3])

      OfferedCourses.create_missing_attendance_notifications([teacher2])
      notification =
        Notification
        |> Repo.one()
        |> Repo.preload(:user)

      assert notification.user == teacher2
      assert notification.type == "attendance_missing"
      assert notification.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course.id)
    end

    test "when multiple offered_course with multiple teacher have missing attendance and some teachers can get notification" do
      students = insert_list(3, :student)
      [teacher1, teacher2, teacher3] = insert_list(3, :teacher)
      [class1, class2, class3] = insert_list(3, :class, date: Timex.shift(Timex.now(), days: -2))

      Enum.each(students, fn(student) ->
       insert(:attendance, student: student, class: class1, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class2, attendance_type: "Not filled")
       insert(:attendance, student: student, class: class3, attendance_type: "Not filled")
      end)

      offered_course1 = insert(:offered_course, classes: [class1, class2], students: students, teachers: [teacher1])
      offered_course2 = insert(:offered_course, classes: [class3], students: students, teachers: [teacher2, teacher3])

      OfferedCourses.create_missing_attendance_notifications([teacher1, teacher3] ++ students)
      [notification1, notification2] =
        Notification
        |> Repo.all()
        |> Repo.preload(:user)
        |> Enum.sort(&(&1.user.id <= &2.user.id))

      assert notification1.user == teacher1
      assert notification1.type == "attendance_missing"
      assert notification1.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course1.id)

      assert notification2.user == teacher3
      assert notification2.type == "attendance_missing"
      assert notification2.resource_path == Attendances.get_offered_course_fill_attendance_path(offered_course2.id)
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
