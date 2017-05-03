defmodule CoursePlanner.CoordinatorControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  alias CoursePlanner.Coordinators

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
    conn = get conn, coordinator_path(conn, :index)
    assert html_response(conn, 200) =~ "Coordinator list"
  end

  test "shows chosen resource", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = get conn, coordinator_path(conn, :show, coordinator)
    assert html_response(conn, 200) =~ "Show coordinator"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, coordinator_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = get conn, coordinator_path(conn, :edit, coordinator)
    assert html_response(conn, 200) =~ "Edit coordinator"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = put conn, coordinator_path(conn, :update, coordinator), user: @valid_attrs
    assert redirected_to(conn) == coordinator_path(conn, :show, coordinator)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = put conn, coordinator_path(conn, :update, coordinator), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit coordinator"
  end

  test "deletes chosen resource", %{conn: conn} do
    {:ok, coordinator} = Coordinators.new(@valid_attrs, "whatever")
    conn = delete conn, coordinator_path(conn, :delete, coordinator)
    assert redirected_to(conn) == coordinator_path(conn, :index)
    assert Repo.get(User, coordinator.id).deleted_at
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, coordinator_path(conn, :new)
    assert html_response(conn, 200) =~ "New coordinator"
  end
end
