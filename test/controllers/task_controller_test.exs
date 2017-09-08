defmodule CoursePlanner.TaskControllerTest do
  use CoursePlannerWeb.ConnCase
  alias CoursePlanner.{Tasks.Task, Repo}

  import CoursePlanner.Factory

  @valid_attrs %{name: "some content", max_volunteers: 2, start_time: Timex.now(), finish_time: Timex.shift(Timex.now(), days: 2), description: "sample rtask description"}
  @invalid_attrs %{}

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)

    {:ok, conn: conn, user: user}
  end

  @moduletag user_role: :student
  describe "student access" do
    test "does not list entries", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :index)
      assert html_response(conn, 403)
    end

    test "does not show chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = get conn, task_path(conn, :show, task)
      assert html_response(conn, 403)
    end

    test "does not renders form for editing", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = get conn, task_path(conn, :edit, task)
      assert html_response(conn, 403)
    end

    test "does not update a chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = put conn, task_path(conn, :update, task), task: @valid_attrs
      assert html_response(conn, 403)
    end

    test "does not delete a chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = delete conn, task_path(conn, :delete, task)
      assert html_response(conn, 403)
    end

    test "does not render for for new resources for non-coordinator users", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :new)
      assert html_response(conn, 403)
    end

    test "does not create task", %{conn: conn, user: _user} do
      conn = post conn, task_path(conn, :create), task: @valid_attrs
      assert html_response(conn, 403)
    end

    test "does not grab a task", %{conn: conn, user: user} do
      task = insert(:task)
      conn = assign(conn, :current_user, user)

      conn = post conn, task_grab_path(conn, :grab, task)
      assert html_response(conn, 403)
    end

    test "does not drop a task", %{conn: conn, user: user} do
      task = insert(:task, volunteers: [user])
      conn = assign(conn, :current_user, user)

      conn = post conn, task_drop_path(conn, :drop, task)
      assert html_response(conn, 403)
    end
  end

  @moduletag user_role: :teacher
  describe "teacher access" do
    test "does not list entries", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :index)
      assert html_response(conn, 403)
    end

    test "does not show chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = get conn, task_path(conn, :show, task)
      assert html_response(conn, 403)
    end

    test "does not renders form for editing", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = get conn, task_path(conn, :edit, task)
      assert html_response(conn, 403)
    end

    test "does not update a chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = put conn, task_path(conn, :update, task), task: @valid_attrs
      assert html_response(conn, 403)
    end

    test "does not delete a chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = delete conn, task_path(conn, :delete, task)
      assert html_response(conn, 403)
    end

    test "does not render for for new resources for non-coordinator users", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :new)
      assert html_response(conn, 403)
    end

    test "does not create task", %{conn: conn, user: _user} do
      conn = post conn, task_path(conn, :create), task: @valid_attrs
      assert html_response(conn, 403)
    end

    test "does not grab a task", %{conn: conn, user: user} do
      task = insert(:task)
      conn = assign(conn, :current_user, user)

      conn = post conn, task_grab_path(conn, :grab, task)
      assert html_response(conn, 403)
    end

    test "does not drop a task", %{conn: conn, user: user} do
      task = insert(:task, volunteers: [user])
      conn = assign(conn, :current_user, user)

      conn = post conn, task_drop_path(conn, :drop, task)
      assert html_response(conn, 403)
    end
  end

  @moduletag user_role: :coordinator
  describe "coordinator access" do
    test "lists all entries on index", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :index)
      assert html_response(conn, 200) =~ "Tasks"
    end

    test "renders form for new resources", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :new)
      assert html_response(conn, 200) =~ "New task"
    end

    test "create task without assigned volunteer", %{conn: conn, user: _user} do
      conn = post conn, task_path(conn, :create), task: @valid_attrs
      assert redirected_to(conn) == task_path(conn, :index)
      reloaded_task = Repo.get_by(Task, @valid_attrs) |> Repo.preload(:volunteers)
      assert reloaded_task.volunteers == []
    end

    test "create task with assigned volunteer", %{conn: conn, user: _user} do
      volunteer = insert(:volunteer)
      task = Map.put(@valid_attrs, :volunteer_ids, [volunteer.id])
      conn = post conn, task_path(conn, :create), task: task
      assert redirected_to(conn) == task_path(conn, :index)
      reloaded_task = Repo.get_by!(Task, name: "some content") |> Repo.preload(:volunteers)
      assert reloaded_task.volunteers == [volunteer]
    end

    test "does not create task volunteers are more than max", %{conn: conn, user: _user} do
      volunteers = insert_list(3, :volunteer)
      task = Map.put(@valid_attrs, :volunteer_ids, Enum.map(volunteers, &(&1.id)))
      conn = post conn, task_path(conn, :create), task: task
      assert html_response(conn, 200) =~ "New task"
    end

    test "does not create task that is expired", %{conn: conn, user: _user} do
      volunteers = insert_list(3, :volunteer)
      updated_attributes = %{@valid_attrs| start_time: Timex.shift(Timex.now(), days: -2), finish_time: Timex.shift(Timex.now(), days: -1)}
      task = Map.put(updated_attributes, :volunteer_ids, Enum.map(volunteers, &(&1.id)))
      conn = post conn, task_path(conn, :create), task: task
      assert html_response(conn, 200) =~ "New task"
      assert  html_response(conn, 200) =~ "Task is expired"
    end

    test "does not create task with invalid data", %{conn: conn, user: _user} do
      conn = post conn, task_path(conn, :create), task: @invalid_attrs
      assert html_response(conn, 200) =~ "New task"
    end

    test "shows chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)
      conn = get conn, task_path(conn, :show, task)
      assert html_response(conn, 200) =~ task.name
    end

    test "renders page not found when id is nonexistent", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :show, -1)
      assert html_response(conn, 404)
    end

    test "renders form for editing chosen resource", %{conn: conn, user: _user} do
      task = Repo.insert! %Task{name: "Clean the whole thing"}
      conn = get conn, task_path(conn, :edit, task)
      assert html_response(conn, 200) =~ "Clean the whole thing"
    end

    test "does not renders form for editing for non-existing task", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :edit, -1)
      assert html_response(conn, 404)
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn, user: _user} do
      task = insert(:task)
      conn = put conn, task_path(conn, :update, task), task: @valid_attrs
      assert redirected_to(conn) == task_path(conn, :show, task)
      assert Repo.get_by(Task, @valid_attrs)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: _user} do
      task = Repo.insert! %Task{name: "Clean the whole thing"}
      conn = put conn, task_path(conn, :update, task), task: @invalid_attrs
      assert html_response(conn, 200) =~ "Clean the whole thing"
    end

    test "does not update chosen resource when added volunteers pass the max", %{conn: conn, user: _user} do
      [volunteer1, volunteer2] = insert_list(2, :volunteer)
      task = insert(:task, max_volunteers: 1, volunteers: [volunteer1])
      task_params = Map.put(@valid_attrs, :volunteer_ids, [volunteer1.id, volunteer2.id])

      conn = put conn, task_path(conn, :update, task), task: %{task_params | max_volunteers: 1}
      assert html_response(conn, 200) =~ @valid_attrs.name
    end

    test "does not update chosen resource when decreasing max_volunteers becomes less than current volunteers", %{conn: conn, user: _user} do
      volunteers = insert_list(2, :volunteer)
      task = insert(:task, volunteers: volunteers)
      task_params = Map.put(@valid_attrs, :volunteer_ids, Enum.map(volunteers, &(&1.id)))

      conn = put conn, task_path(conn, :update, task), task: %{task_params | max_volunteers: 1}
      assert html_response(conn, 200) =~ @valid_attrs.name
    end

    test "does not update a non-existing resource", %{conn: conn, user: _user} do
      conn = put conn, task_path(conn, :update, -1), task: @invalid_attrs
      assert html_response(conn, 404)
    end

    test "deletes chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)
      conn = delete conn, task_path(conn, :delete, task)
      assert redirected_to(conn) == task_path(conn, :index)
      refute Repo.get(Task, task.id)
    end

    test "does not delete a non-existing resource", %{conn: conn, user: _user} do
      conn = delete conn, task_path(conn, :delete, -1)
      assert redirected_to(conn) == task_path(conn, :index)
      assert conn.private.plug_session == %{"phoenix_flash" => %{"error" => "Task was not found."}}
    end

    test "does not grab a task", %{conn: conn, user: user} do
      task = insert(:task)
      conn = assign(conn, :current_user, user)

      conn = post conn, task_grab_path(conn, :grab, task)
      assert html_response(conn, 403)
    end

    test "does not drop a task", %{conn: conn, user: user} do
      task = insert(:task, volunteers: [user])
      conn = assign(conn, :current_user, user)

      conn = post conn, task_drop_path(conn, :drop, task)
      assert html_response(conn, 403)
    end
  end

  @moduletag user_role: :volunteer
  describe "volunteer access" do
    test "lists all entries on index", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :index)
      assert html_response(conn, 200) =~ "Your tasks"
    end

    test "shows chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)
      conn = get conn, task_path(conn, :show, task)
      assert html_response(conn, 200) =~ task.name
    end

    test "renders page not found when id is nonexistent", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :show, -1)
      assert html_response(conn, 404)
    end

    test "does not renders form for editing", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = get conn, task_path(conn, :edit, task)
      assert html_response(conn, 403)
    end

    test "does not update a chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = put conn, task_path(conn, :update, task), task: @valid_attrs
      assert html_response(conn, 403)
    end

    test "does not delete a chosen resource", %{conn: conn, user: _user} do
      task = insert(:task)

      conn = delete conn, task_path(conn, :delete, task)
      assert html_response(conn, 403)
    end

    test "does not render for for new resources for non-coordinator users", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :new)
      assert html_response(conn, 403)
    end

    test "does not create task", %{conn: conn, user: _user} do
      conn = post conn, task_path(conn, :create), task: @valid_attrs
      assert html_response(conn, 403)
    end

    test "index sorted by freshness", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :index, sort: "fresh")
      assert html_response(conn, 200) =~ "Your tasks"
    end

    test "index sorted by closeness", %{conn: conn, user: _user} do
      conn = get conn, task_path(conn, :index, sort: "closest")
      assert html_response(conn, 200) =~ "Your tasks"
    end

    test "grab a task", %{conn: conn, user: user} do
      task = insert(:task)

      conn = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn) == task_path(conn, :index)

      reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
      assert  reloaded_task.volunteers == [user]
    end

    test "grab the last empty place in a task", %{conn: conn, user: user} do
      volunteers = insert_list(2, :volunteer)
      task = insert(:task, max_volunteers: 3, volunteers: volunteers)

      conn = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn) == task_path(conn, :index)

      reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
      assert length(reloaded_task.volunteers) == 3
      assert Enum.any?(reloaded_task.volunteers, &(&1 == user))
    end

    test "does not grab a non-existing resource", %{conn: conn, user: _user} do
      conn = post conn, task_grab_path(conn, :grab, -1)
      assert redirected_to(conn) == task_path(conn, :index)
      assert conn.private.plug_session == %{"phoenix_flash" => %{"error" => "Task was not found."}}
    end

    test "does not grab when max_volunteer is reached", %{conn: conn, user: _user} do
      volunteers = insert_list(2, :volunteer)
      task = insert(:task, max_volunteers: 2, volunteers: volunteers)

      conn = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn) == task_path(conn, :index)
      assert conn.private.plug_session == %{"phoenix_flash" => %{"error" => "The maximum number of volunteers needed for this task is reached"}}
    end

    test "does not grab an expired task", %{conn: conn, user: _user} do
      volunteers = insert_list(2, :volunteer)
      task = insert(:task, max_volunteers: 3, volunteers: volunteers, start_time:  Timex.shift(Timex.now(), days: -2), finish_time: Timex.shift(Timex.now(), days: -1))

      conn = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn) == task_path(conn, :index)
      assert conn.private.plug_session == %{"phoenix_flash" => %{"error" => "Task is expired"}}
    end

    test "grab an already task doesn't add the volunteer twice", %{conn: conn, user: user} do
      task = insert(:task)

      conn1 = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn1) == task_path(conn1, :index)
      conn2 = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn2) == task_path(conn2, :index)
      conn3 = post conn, task_grab_path(conn, :grab, task)
      assert redirected_to(conn3) == task_path(conn3, :index)

      reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
      assert  reloaded_task.volunteers == [user]
    end

    test "does not drop a non-existing resource", %{conn: conn, user: _user} do
      conn = post conn, task_drop_path(conn, :drop, -1)
      assert redirected_to(conn) == task_path(conn, :index)
      assert conn.private.plug_session == %{"phoenix_flash" => %{"error" => "Task was not found."}}
    end

    test "drop a task with only one volunteer", %{conn: conn, user: user} do
      task = insert(:task, volunteers: [user])

      conn = post conn, task_drop_path(conn, :drop, task)
      assert redirected_to(conn) == task_path(conn, :index)

      reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
      assert  reloaded_task.volunteers == []
    end

    test "drop a task with multiple volunteer", %{conn: conn, user: user} do
      volunteers = insert_list(2, :volunteer)

      task = insert(:task, max_volunteers: 3, volunteers: [user | volunteers])

      conn = post conn, task_drop_path(conn, :drop, task)
      assert redirected_to(conn) == task_path(conn, :index)

      reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
      assert reloaded_task.volunteers == volunteers
    end

    test "drop a task even if number of volunteers are more than max_volunteers", %{conn: conn, user: user} do
      volunteers = insert_list(10, :volunteer)

      task = insert(:task, max_volunteers: 3, volunteers: [user | volunteers])

      conn = post conn, task_drop_path(conn, :drop, task)
      assert redirected_to(conn) == task_path(conn, :index)

      reloaded_task = Repo.get(Task, task.id) |> Repo.preload(:volunteers)
      assert reloaded_task.volunteers == volunteers
    end

    test "does not drop an expired task", %{conn: conn, user: user} do
      volunteers = insert_list(2, :volunteer)

      task = insert(:task, max_volunteers: 3, volunteers: [user | volunteers], start_time:  Timex.shift(Timex.now(), days: -2), finish_time: Timex.shift(Timex.now(), days: -1))

      conn = post conn, task_drop_path(conn, :drop, task)
      assert redirected_to(conn) == task_path(conn, :index)
      assert conn.private.plug_session == %{"phoenix_flash" => %{"error" => "Task is expired"}}
    end
  end
end
