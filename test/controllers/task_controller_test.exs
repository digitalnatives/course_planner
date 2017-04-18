defmodule CoursePlanner.TaskControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.User

  alias CoursePlanner.Task
  @valid_attrs %{due: %{day: 17, month: 4, year: 2010}, name: "some content"}
  @invalid_attrs %{}
  @user %User{
    first_name: "Test User",
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
    conn = get conn, task_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing tasks"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, task_path(conn, :new)
    assert html_response(conn, 200) =~ "New task"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, task_path(conn, :create), task: @valid_attrs
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get_by(Task, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, task_path(conn, :create), task: @invalid_attrs
    assert html_response(conn, 200) =~ "New task"
  end

  test "shows chosen resource", %{conn: conn} do
    task = Repo.insert! %Task{}
    conn = get conn, task_path(conn, :show, task)
    assert html_response(conn, 200) =~ "Show task"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, task_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    task = Repo.insert! %Task{}
    conn = get conn, task_path(conn, :edit, task)
    assert html_response(conn, 200) =~ "Edit task"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    task = Repo.insert! %Task{}
    conn = put conn, task_path(conn, :update, task), task: @valid_attrs
    assert redirected_to(conn) == task_path(conn, :show, task)
    assert Repo.get_by(Task, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    task = Repo.insert! %Task{}
    conn = put conn, task_path(conn, :update, task), task: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit task"
  end

  test "deletes chosen resource", %{conn: conn} do
    task = Repo.insert! %Task{}
    conn = delete conn, task_path(conn, :delete, task)
    assert redirected_to(conn) == task_path(conn, :index)
    refute Repo.get(Task, task.id)
  end
end
