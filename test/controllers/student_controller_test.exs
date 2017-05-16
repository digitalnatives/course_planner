defmodule CoursePlanner.StudentControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, User, Students}
  alias CoursePlanner.Terms.Term

  @valid_attrs %{name: "some content", email: "valid@email"}
  @invalid_attrs %{}
  @user %User{
    name: "Test User",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret"}

  defp create_term(name, start_date, end_date, course) do
     Repo.insert!(
       %Term{
         name: name,
         start_date: start_date,
         end_date: end_date,
         courses: [course],
         status: "Planned"
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


  setup do
    conn =
      Phoenix.ConnTest.build_conn()
        |> assign(:current_user, @user)
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, student_path(conn, :index)
    assert html_response(conn, 200) =~ "Student list"
  end

  test "shows chosen resource", %{conn: conn} do
    student = Repo.insert! %User{}
    conn = get conn, student_path(conn, :show, student)
    assert html_response(conn, 200) =~ "Show student"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, student_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    student = Repo.insert! %User{}
    conn = get conn, student_path(conn, :edit, student)
    assert html_response(conn, 200) =~ "Edit student"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    student = Repo.insert! %User{}
    conn = put conn, student_path(conn, :update, student), user: @valid_attrs
    assert redirected_to(conn) == student_path(conn, :show, student)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    student = Repo.insert! %User{}
    conn = put conn, student_path(conn, :update, student), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit student"
  end

  test "deletes chosen resource", %{conn: conn} do
    {:ok, student} = Students.new(@valid_attrs, "whatever")
    conn = delete conn, student_path(conn, :delete, student)
    assert redirected_to(conn) == student_path(conn, :index)
    assert Repo.get(User, student.id).deleted_at
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, student_path(conn, :new)
    assert html_response(conn, 200) =~ "New student"
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
