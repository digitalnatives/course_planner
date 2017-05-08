defmodule CoursePlanner.VolunteerControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  alias CoursePlanner.Volunteers

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
    conn = get conn, volunteer_path(conn, :index)
    assert html_response(conn, 200) =~ "Volunteer list"
  end

  test "shows chosen resource", %{conn: conn} do
    volunteer = Repo.insert! %User{}
    conn = get conn, volunteer_path(conn, :show, volunteer)
    assert html_response(conn, 200) =~ "Show volunteer"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, volunteer_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    volunteer = Repo.insert! %User{}
    conn = get conn, volunteer_path(conn, :edit, volunteer)
    assert html_response(conn, 200) =~ "Edit volunteer"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    volunteer = Repo.insert! %User{}
    conn = put conn, volunteer_path(conn, :update, volunteer), user: @valid_attrs
    assert redirected_to(conn) == volunteer_path(conn, :show, volunteer)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    volunteer = Repo.insert! %User{}
    conn = put conn, volunteer_path(conn, :update, volunteer), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit volunteer"
  end

  test "deletes chosen resource", %{conn: conn} do
    {:ok, volunteer} = Volunteers.new(@valid_attrs, "whatever")
    conn = delete conn, volunteer_path(conn, :delete, volunteer)
    assert redirected_to(conn) == volunteer_path(conn, :index)
    assert Repo.get(User, volunteer.id).deleted_at
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, volunteer_path(conn, :new)
    assert html_response(conn, 200) =~ "New volunteer"
  end
end
