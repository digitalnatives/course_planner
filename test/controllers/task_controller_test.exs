defmodule CoursePlanner.TaskControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.{Tasks, Volunteers, Repo, User}
  alias CoursePlanner.Tasks.Task

  @valid_attrs %{name: "some content", start_time: Timex.now(), finish_time: Timex.now()}
  @invalid_attrs %{}
  @user %User{
    name: "Test User",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Coordinator"}
  @volunteer %{
    name: "Test Volunteer",
    email: "volunteer@courseplanner.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Volunteer"}

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

  test "shows chosen resource", %{conn: conn} do
    task = Repo.insert! %Task{}
    conn = get conn, task_path(conn, :show, task)
    assert html_response(conn, 200) =~ "Show task"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, task_path(conn, :show, -1)
    assert html_response(conn, 404)
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
    {:ok, task} = Tasks.new(@valid_attrs)
    conn = delete conn, task_path(conn, :delete, task)
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get(Task, task.id).deleted_at
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, task_path(conn, :new)
    assert html_response(conn, 200) =~ "New task"
  end

  test "create task without assigned volunteer", %{conn: conn} do
    conn = post conn, task_path(conn, :create), task: @valid_attrs
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get_by(Task, name: "some content")
  end

  test "create task with assigned volunteer", %{conn: conn} do
    {:ok, volunteer} = Volunteers.new(@volunteer, "whatever")
    task = Map.put(@valid_attrs, :user_id, volunteer.id)
    conn = post conn, task_path(conn, :create), task: task
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get_by!(Task, name: "some content").user_id == volunteer.id
  end

<<<<<<< HEAD
=======
  test "mark task as done", %{conn: conn} do
    {:ok, volunteer} = Volunteers.new(@volunteer, "whatever")
    task = Map.put(@valid_attrs, :user_id, volunteer.id)
    {:ok, task} = Tasks.new(task)
    conn = post conn, task_done_path(conn, :done, task)
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get_by!(Task, name: "some content").status == "Accomplished"
  end

>>>>>>> Remove commented code.
  test "grab task", %{conn: conn} do
    {:ok, task} = Tasks.new(@valid_attrs)
    {:ok, volunteer} = Volunteers.new(@volunteer, "whatever")
    conn = assign(conn, :current_user, volunteer)
    conn = post conn, task_grab_path(conn, :grab, task)
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get_by!(Task, name: "some content").user_id == volunteer.id
  end
end
