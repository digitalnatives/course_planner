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

end
