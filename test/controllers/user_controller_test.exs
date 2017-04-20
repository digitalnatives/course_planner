defmodule CoursePlanner.UserControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User

  @valid_attrs %{name: "some content", email: "some content"}
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
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "User list"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, invitation_path(conn, :new)
    assert html_response(conn, 200) =~ "Invite user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
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

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
