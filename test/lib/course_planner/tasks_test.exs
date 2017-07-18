defmodule CoursePlanner.TasksTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Tasks, Users, Tasks.Task}
  import CoursePlanner.Factory

  test "assign volunteer to task" do
    task = insert(:task)
    volunteer = insert(:volunteer)
    {:ok, task} = Tasks.update(task.id, %{user_id: volunteer.id})
    assert task.user_id == volunteer.id
  end

  test "unassign task when volunteer is deleted" do
    volunteer = insert(:volunteer)
    task = insert(:task)
    refute task.user_id
    {:ok, task} = Tasks.update(task.id, %{user_id: volunteer.id})
    Users.delete(volunteer.id)
    assert Users.get(volunteer.id) == {:error, :not_found}
    {:ok, updated_task} = Tasks.get(task.id)
    refute updated_task.user_id
  end

  test "query without sort option" do
    task1 = insert(:task)
    task2 = insert(:task)
    task3 = insert(:task)
    result = Tasks.task_query(nil) |> Repo.all() |> Enum.map(&(&1.id))
    assert result == [task1.id, task2.id, task3.id]
  end

  test "query sorted by freshness" do
    task1 = insert(:task)
    task2 = insert(:task)
    task3 = insert(:task)
    result = Tasks.task_query("fresh") |> Repo.all() |> Enum.map(&(&1.id))
    assert result == [task3.id, task2.id, task1.id]
    {:ok, _task2} = task2 |> Task.changeset(%{name: "updated name"}) |> Repo.update()
    result2 = Tasks.task_query("fresh") |> Repo.all() |> Enum.map(&(&1.id))
    assert result2 == [task2.id, task3.id, task1.id]
  end

  test "query sorted by closeness" do
    task1 = insert(:task, %{finish_time: ~N[2017-01-01 01:00:00]})
    task2 = insert(:task, %{finish_time: ~N[2017-01-02 01:00:00]})
    task3 = insert(:task, %{finish_time: ~N[2017-01-02 02:00:00]})
    result = Tasks.task_query("closest") |> Repo.all() |> Enum.map(&(&1.id))
    assert result == [task1.id, task2.id, task3.id]
  end

  test "do not grab task when it has expired" do
    task = insert(:task, %{finish_time: Timex.now() |> Timex.shift(days: -1)})
    volunteer = insert(:volunteer)
    assert Tasks.grab(task.id, volunteer.id, Timex.now()) == {:error, :already_finished}
  end

  test "do not list finished tasks" do
    volunteer = insert(:volunteer)
    insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: -1)})
    task = insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: 1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
    [applicable_task] = Tasks.get_for_user(nil, volunteer.id, Timex.now())
    assert applicable_task.id == task.id
  end

  test "do not list expired tasks" do
    volunteer = insert(:volunteer)
    insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: -1)})
    insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: 1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
    task = insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
    [applicable_task] = Tasks.get_unassigned(nil, Timex.now())
    assert applicable_task.id == task.id
  end

  test "do not grab task that is already assigned" do
    volunteer1 = insert(:volunteer)
    volunteer2 = insert(:volunteer)
    task = insert(:task, %{user_id: volunteer1.id})
    assert Tasks.grab(task.id, volunteer2.id, ~N[2017-01-01 02:00:00]) == {:error, :already_assigned}
  end

  test "query past tasks" do
    volunteer = insert(:volunteer)
    task1 = insert(:task, %{finish_time: ~N[2017-01-01 02:00:00], user_id: volunteer.id})
    task2 = insert(:task, %{finish_time: ~N[2017-01-02 02:00:00], user_id: volunteer.id})
    insert(:task, %{finish_time: ~N[2017-01-02 08:00:00], user_id: volunteer.id})
    insert(:task, %{finish_time: ~N[2017-01-03 02:00:00], user_id: volunteer.id})
    result = Tasks.get_past(nil, volunteer.id, ~N[2017-01-02 05:00:00]) |> Enum.map(&(&1.id))
    assert result == [task1.id, task2.id]
  end

end
