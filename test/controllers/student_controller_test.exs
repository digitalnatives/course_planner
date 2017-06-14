defmodule CoursePlanner.StudentControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.{Repo, User, Students}
  import CoursePlanner.Factory

  @valid_attrs %{name: "some content", email: "valid@email"}
  @invalid_attrs %{}

  setup do
    {:ok, conn: login_as(:coordinator)}
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
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
    refute Repo.get(User, student.id)
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, student_path(conn, :new)
    assert html_response(conn, 200) =~ "New student"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    student = insert(:student)

    conn = get student_conn, student_path(student_conn, :show, student)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :show, student)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :show, student)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, student_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    student = insert(:student)

    conn = get student_conn, student_path(student_conn, :edit, student)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :edit, student)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :edit, student)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    student = insert(:student)

    conn = delete student_conn, student_path(student_conn, :delete, student.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, student_path(teacher_conn, :delete, student.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, student_path(volunteer_conn, :delete, student.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new class for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, student_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not update chosen student for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    student = Repo.insert! %User{}

    conn = put student_conn, student_path(student_conn, :update, student), student: @valid_attrs
    assert html_response(conn, 403)

    conn = put teacher_conn, student_path(teacher_conn, :update, student), student: @valid_attrs
    assert html_response(conn, 403)

    conn = put volunteer_conn, student_path(volunteer_conn, :update, student), student: @valid_attrs
    assert html_response(conn, 403)
  end

  test "show the student himself" do
    student = insert(:student)
    student_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, student)

    conn = get student_conn, student_path(student_conn, :show, student)
    assert html_response(conn, 200) =~ "Show student"
  end

  test "edit the student himself" do
    student = insert(:student)
    student_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, student)

    conn = get student_conn, student_path(student_conn, :edit, student)
    assert html_response(conn, 200) =~ "Edit student"
  end

  test "update the student himself" do
    student = insert(:student)
    student_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, student)

    conn = put student_conn, student_path(student_conn, :update, student), user: @valid_attrs
    assert redirected_to(conn) == student_path(conn, :show, student)
    assert Repo.get_by(User, @valid_attrs)
  end

end
