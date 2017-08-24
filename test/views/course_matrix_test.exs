defmodule CoursePlanner.CourseMatrixViewTest do
  use CoursePlannerWeb.ConnCase, async: true

  alias CoursePlannerWeb.CourseMatrixView
  import CoursePlanner.Factory

  test "course_name/1" do
    course = insert(:course)
    offered_course1 = insert(:offered_course)
    offered_course2 = insert(:offered_course, course: course)
    offered_courses =
      %{ offered_course1.id => offered_course1,
         offered_course2.id => offered_course2 }
    assert course.name == CourseMatrixView.course_name(offered_courses, offered_course2.id)
  end

  test "total_students/1" do
    student_list1 = insert_list(6, :student)
    student_list2 = insert_list(4, :student)

    offered_course1 = insert(:offered_course, students: student_list1)
    offered_course2 = insert(:offered_course, students: student_list2)

    offered_courses =
      %{ offered_course1.id => offered_course1,
         offered_course2.id => offered_course2 }

    assert 6 == CourseMatrixView.total_students(offered_courses, offered_course1.id)
    assert 4 == CourseMatrixView.total_students(offered_courses, offered_course2.id)
  end
end
