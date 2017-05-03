defmodule CoursePlanner.TeacherControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  alias CoursePlanner.Teachers

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
end
