defmodule CoursePlanner.StudentsTest do
  use CoursePlannerWeb.ModelCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, Students}
  alias CoursePlanner.Terms.Term

  @valid_attrs %{"name" => "some content", "email" => "valid@email"}

  defp create_term(name, start_date, end_date, course) do
     Repo.insert!(
       %Term{
         name: name,
         start_date: start_date,
         end_date: end_date,
         minimum_teaching_days: 5,
         courses: [course]
       })
   end

  defp create_course(name) do
   Repo.insert!(
     Course.changeset(
       %Course{},
       %{
         name: name,
         description: "Description",
         number_of_sessions: 1,
         session_duration: "01:00:00",
         status: "Active"
       }))
  end

  defp create_offered_course(term, course, students) do
   Repo.insert!(
     %OfferedCourse
     {
       term_id: term.id,
       course_id: course.id,
       students: students
     }
   )
  end

  test "gets empty list when student has no course assigned" do
    {:ok, student} = Students.new(@valid_attrs, "whatever")
    assert Students.courses(student.id) == []
  end

  test "gets list of courses when student has assigned courses" do
    course = create_course("english")
    term = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    {:ok, student} = Students.new(@valid_attrs, "whatever")
    create_offered_course(term, course, [student])
    student_courses = Students.courses(student.id)

    assert course.id == List.first(student_courses).course.id
    assert term.id == List.first(student_courses).term.id
  end

  test "gets list of courses ordered descendingly by term starting_date when student has multiple courses assigned to" do
    course = create_course("english")
    term1 = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    {:ok, student} = Students.new(@valid_attrs, "whatever")
    term2 = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2018},
                       %Ecto.Date{day: 1, month: 6, year: 2018},
                       course)
    create_offered_course(term1, course, [student])
    create_offered_course(term2, course, [student])
    student_courses = Students.courses(student.id)

    assert course.id == List.first(student_courses).course.id
    assert term2.id == List.first(student_courses).term.id
    assert course.id == List.last(student_courses).course.id
    assert term1.id == List.last(student_courses).term.id
  end
end
