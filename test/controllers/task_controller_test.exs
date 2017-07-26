defmodule CoursePlanner.TaskControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.{Tasks.Task, Repo}

  import CoursePlanner.Factory

  @valid_attrs %{name: "some content", max_volunteer: 2, start_time: Timex.now(), finish_time: Timex.shift(Timex.now(), days: 2), description: "sample rtask description"}
  @invalid_attrs %{}

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
        |> assign(:current_user, insert(:coordinator))
    {:ok, conn: conn}
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "lists all entries on index for volunteer and coordinator", %{conn: _conn} do
    volunteer_conn = login_as(:volunteer)
    coordinator_conn = login_as(:coordinator)

    conn = get volunteer_conn, task_path(volunteer_conn, :index)
    assert html_response(conn, 200) =~ "Your tasks"

    conn = get coordinator_conn, task_path(coordinator_conn, :index)
    assert html_response(conn, 200) =~ "Tasks"
  end

  test "does not list entries for restricted users", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)

    conn = get student_conn, task_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, task_path(teacher_conn, :index)
    assert html_response(conn, 403)
  end

  test "shows chosen resource", %{conn: conn} do
    task = insert(:task)
    conn = get conn, task_path(conn, :show, task)
    assert html_response(conn, 200) =~ task.name
  end

  test "does not show chosen resource for student and teacher", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)

    task = insert(:task)

    conn = get student_conn, task_path(student_conn, :show, task)
    assert html_response(conn, 403)

    conn = get teacher_conn, task_path(teacher_conn, :show, task)
    assert html_response(conn, 403)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, task_path(conn, :show, -1)
    assert html_response(conn, 404)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    task = Repo.insert! %Task{name: "Clean the whole thing"}
    conn = get conn, task_path(conn, :edit, task)
    assert html_response(conn, 200) =~ "Clean the whole thing"
  end

  test "does not renders form for editing for non-existing task", %{conn: conn} do
    conn = get conn, task_path(conn, :edit, -1)
    assert html_response(conn, 404)
  end

  test "does not renders form for editing for non-coordinator users", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    task = insert(:task)

    conn = get student_conn, task_path(student_conn, :edit, task)
    assert html_response(conn, 403)

    conn = get teacher_conn, task_path(teacher_conn, :edit, task)
    assert html_response(conn, 403)

    conn = get volunteer_conn, task_path(volunteer_conn, :edit, task)
    assert html_response(conn, 403)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    task = insert(:task)
    conn = put conn, task_path(conn, :update, task), task: @valid_attrs
    assert redirected_to(conn) == task_path(conn, :show, task)
    assert Repo.get_by(Task, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    task = Repo.insert! %Task{name: "Clean the whole thing"}
    conn = put conn, task_path(conn, :update, task), task: @invalid_attrs
    assert html_response(conn, 200) =~ "Clean the whole thing"
  end

  test "does not update a chosen resource for non-coordinator users", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    task = insert(:task)

    conn = put student_conn, task_path(student_conn, :update, task), task: @valid_attrs
    assert html_response(conn, 403)

    conn = put teacher_conn, task_path(teacher_conn, :update, task), task: @valid_attrs
    assert html_response(conn, 403)

    conn = put volunteer_conn, task_path(volunteer_conn, :update, task), task: @valid_attrs
    assert html_response(conn, 403)
  end

  test "deletes chosen resource", %{conn: conn} do
    task = insert(:task)
    conn = delete conn, task_path(conn, :delete, task)
    assert redirected_to(conn) == task_path(conn, :index)
    refute Repo.get(Task, task.id)
  end

  test "does not delete a non-existing resource", %{conn: conn} do
    conn = delete conn, task_path(conn, :delete, -1)
    assert redirected_to(conn) == task_path(conn, :index)
    conn = get conn, task_path(conn, :index)
    assert  html_response(conn, 200) =~ "Task was not found"
  end

  test "does not delete a chosen resource for non-coordinator users", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    task = insert(:task)

    conn = delete student_conn, task_path(student_conn, :delete, task)
    assert html_response(conn, 403)

    conn = delete teacher_conn, task_path(teacher_conn, :delete, task)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, task_path(volunteer_conn, :delete, task)
    assert html_response(conn, 403)
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, task_path(conn, :new)
    assert html_response(conn, 200) =~ "New task"
  end

  test "does not render for for new resources for non-coordinator users", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, task_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, task_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, task_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "create task without assigned volunteer", %{conn: conn} do
    conn = post conn, task_path(conn, :create), task: @valid_attrs
    assert redirected_to(conn) == task_path(conn, :index)
    assert Repo.get_by(Task, name: "some content")
  end

  test "create task with assigned volunteer", %{conn: conn} do
    volunteer = insert(:volunteer)
    task = Map.put(@valid_attrs, :volunteer_ids, [volunteer.id])
    conn = post conn, task_path(conn, :create), task: task
    assert redirected_to(conn) == task_path(conn, :index)
    reloaded_task = Repo.get_by!(Task, name: "some content") |> Repo.preload(:volunteers)
    assert reloaded_task.volunteers == [volunteer]
  end

  test "does not create task with invalid data", %{conn: conn} do
    conn = post conn, task_path(conn, :create), task: @invalid_attrs
    assert html_response(conn, 200) =~ "New task"
  end

  test "does not create task for non-coordinator users", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = post student_conn, task_path(student_conn, :create), task: @valid_attrs
    assert html_response(conn, 403)

    conn = post teacher_conn, task_path(teacher_conn, :create), task: @valid_attrs
    assert html_response(conn, 403)

    conn = post volunteer_conn, task_path(volunteer_conn, :create), task: @valid_attrs
    assert html_response(conn, 403)
  end

  test "grab task", %{conn: conn} do
    task = insert(:task, %{
      start_time: Timex.now() |> Timex.shift(days: 1),
      finish_time: Timex.now() |> Timex.shift(days: 1) |> Timex.shift(hours: 1)})
    volunteer = insert(:volunteer)
    conn = assign(conn, :current_user, volunteer)
    conn = post conn, task_grab_path(conn, :grab, task)
    assert redirected_to(conn) == task_path(conn, :index)

    reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
    assert  reloaded_task.volunteers == [volunteer]
  end

  test "does not grab a non-existing resource", %{conn: _conn} do
    volunteer_conn = login_as(:volunteer)

    conn = post volunteer_conn, task_grab_path(volunteer_conn, :grab, -1)
    assert redirected_to(conn) == task_path(conn, :index)
    conn = get conn, task_path(conn, :index)
    assert  html_response(conn, 200) =~ "Task was not found"
  end

  test "index sorted by freshness" do
    volunteer_conn = login_as(:volunteer)

    conn = get volunteer_conn, task_path(volunteer_conn, :index, sort: "fresh")
    assert html_response(conn, 200) =~ "Your tasks"
  end

  test "index sorted by closeness" do
    volunteer_conn = login_as(:volunteer)

    conn = get volunteer_conn, task_path(volunteer_conn, :index, sort: "closest")
    assert html_response(conn, 200) =~ "Your tasks"
  end
end
