defmodule CoursePlanner.TeacherControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, User, Teachers}
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

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
        |> assign(:current_user, @user)
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, teacher_path(conn, :index)
    assert html_response(conn, 200) =~ "Teacher list"
  end

  test "shows chosen resource", %{conn: conn} do
    teacher = Repo.insert! %User{}
    conn = get conn, teacher_path(conn, :show, teacher)
    assert html_response(conn, 200) =~ "Show teacher"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, teacher_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    teacher = Repo.insert! %User{}
    conn = get conn, teacher_path(conn, :edit, teacher)
    assert html_response(conn, 200) =~ "Edit teacher"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    teacher = Repo.insert! %User{}
    conn = put conn, teacher_path(conn, :update, teacher), user: @valid_attrs
    assert redirected_to(conn) == teacher_path(conn, :show, teacher)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    teacher = Repo.insert! %User{}
    conn = put conn, teacher_path(conn, :update, teacher), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit teacher"
  end

  test "deletes chosen resource", %{conn: conn} do
    {:ok, teacher} = Teachers.new(@valid_attrs, "whatever")
    conn = delete conn, teacher_path(conn, :delete, teacher)
    assert redirected_to(conn) == teacher_path(conn, :index)
    assert Repo.get(User, teacher.id).deleted_at
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, teacher_path(conn, :new)
    assert html_response(conn, 200) =~ "New teacher"
  end

  test "gets empty list when teacher has no course assigned" do
    teacher = Repo.insert!(%{@user | role: "Teacher"})
    assert Teachers.courses(teacher.id) == []
  end

  test "gets list of courses when teacher has assigned courses" do
    course = create_course("english")
    term = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    teacher = Repo.insert!(%{@user | role: "Teacher", email: "random1@test.com"})
    create_offered_course(term, course, [teacher])
    teacher_courses = Teachers.courses(teacher.id)

    assert course.id == List.first(teacher_courses).course.id
    assert term.id == List.first(teacher_courses).term.id
  end

  test "gets list of courses ordered decesdingly by term starting_date when teacher has multiple courses assigned to" do
    course = create_course("english")
    term1 = create_term("FALL",
                       %Ecto.Date{day: 1, month: 1, year: 2017},
                       %Ecto.Date{day: 1, month: 6, year: 2017},
                       course)
    teacher = Repo.insert!(%{@user | role: "Teacher", email: "random2@test.com"})
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
