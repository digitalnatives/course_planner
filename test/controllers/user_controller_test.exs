defmodule CoursePlanner.UserControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User

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
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "User list"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, user_path(conn, :show, -1)
    assert html_response(conn, 404)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student)

    conn = get student_conn, user_path(student_conn, :show, user)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :show, user)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :show, user)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, user_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student)

    conn = get student_conn, user_path(student_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :edit, user)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student)

    conn = delete student_conn, user_path(student_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, user_path(teacher_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, user_path(volunteer_conn, :delete, user.id)
    assert html_response(conn, 403)
  end

  test "does not update chosen user for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = Repo.insert! %User{}

    conn = put student_conn, user_path(student_conn, :update, user), user: @valid_attrs
    assert html_response(conn, 403)

    conn = put teacher_conn, user_path(teacher_conn, :update, user), user: @valid_attrs
    assert html_response(conn, 403)

    conn = put volunteer_conn, user_path(volunteer_conn, :update, user), user: @valid_attrs
    assert html_response(conn, 403)
  end

  test "show the user himself" do
    user = insert(:user)
    user_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)

    conn = get user_conn, user_path(user_conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "edit the user himself" do
    user = insert(:user)
    user_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)

    conn = get user_conn, user_path(user_conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "update the user himself" do
    user = insert(:user)
    user_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)

    conn = put user_conn, user_path(user_conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

end
