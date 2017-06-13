defmodule CoursePlanner.TeachersTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, Teachers}
  alias CoursePlanner.Terms.Term

  @valid_attrs %{name: "some content", email: "valid@email"}

  defp create_term(name, start_date, end_date, course) do
    Repo.insert!(
      %Term{
        name: name,
        start_date: start_date,
        end_date: end_date,
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

  defp create_offered_course(term, course, teachers) do
    Repo.insert!(
      %OfferedCourse
      {
        term_id: term.id,
        course_id: course.id,
        teachers: teachers
      }
    )
  end

  test "gets empty list when teacher has no course assigned" do
    {:ok, teacher} = Teachers.new(@valid_attrs, "whatever")
    assert Teachers.courses(teacher.id) == []
  end

  test "gets list of courses when teacher has assigned courses" do
    course = create_course("english")
    term = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    {:ok, teacher} = Teachers.new(@valid_attrs, "whatever")
    create_offered_course(term, course, [teacher])
    teacher_courses = Teachers.courses(teacher.id)

    assert course.id == List.first(teacher_courses).course.id
    assert term.id == List.first(teacher_courses).term.id
  end

  test "gets list of courses ordered descendingly by term starting_date when teacher has multiple courses assigned to" do
    course = create_course("english")
    term1 = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    {:ok, teacher} = Teachers.new(@valid_attrs, "whatever")
    term2 = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2018},
                       %Ecto.Date{day: 1, month: 6, year: 2018},
                       course)
    create_offered_course(term1, course, [teacher])
    create_offered_course(term2, course, [teacher])
    teacher_courses = Teachers.courses(teacher.id)

    assert course.id == List.first(teacher_courses).course.id
    assert term2.id == List.first(teacher_courses).term.id
    assert course.id == List.last(teacher_courses).course.id
    assert term1.id == List.last(teacher_courses).term.id
  end
end
