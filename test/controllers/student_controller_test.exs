defmodule CoursePlanner.StudentControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User

  @valid_attrs %{name: "some content", email: "valid@email"}
  @invalid_attrs %{}
  @user %User{
    name: "Test User",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret"}

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
end
