defmodule CoursePlanner.TasksTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Tasks, Tasks.Task}
  import CoursePlanner.Factory

  test "query without sort option" do
    task1 = insert(:task)
    task2 = insert(:task)
    task3 = insert(:task)
    result = Tasks.task_query(nil) |> Repo.all() |> Enum.map(&(&1.id)) |> Enum.sort()
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

  test "do not list finished tasks" do
    volunteer = insert(:volunteer)
    insert(:task, %{volunteers: [volunteer], finish_time: Timex.now() |> Timex.shift(hours: -1)})
    task = insert(:task, %{volunteers: [volunteer], finish_time: Timex.now() |> Timex.shift(hours: 1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
    [applicable_task] = Tasks.get_for_user(nil, volunteer.id, Timex.now())
    assert applicable_task.id == task.id
  end

  test "do not list expired tasks" do
    volunteer = insert(:volunteer)
    insert(:task, %{volunteers: [volunteer], finish_time: Timex.now() |> Timex.shift(hours: -1)})
    insert(:task, %{volunteers: [volunteer], finish_time: Timex.now() |> Timex.shift(hours: 1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
    task = insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
    [applicable_task] = Tasks.get_availables(nil, volunteer.id, Timex.now())
    assert applicable_task.id == task.id
  end

  test "query past tasks" do
    volunteer = insert(:volunteer)
    task1 = insert(:task, %{finish_time: ~N[2017-01-01 02:00:00], volunteers: [volunteer]})
    task2 = insert(:task, %{finish_time: ~N[2017-01-02 02:00:00], volunteers: [volunteer]})
    insert(:task, %{finish_time: ~N[2017-01-02 08:00:00], volunteers: [volunteer]})
    insert(:task, %{finish_time: ~N[2017-01-03 02:00:00], volunteers: [volunteer]})
    result = Tasks.get_past(nil, volunteer.id, ~N[2017-01-02 05:00:00]) |> Enum.map(&(&1.id))
    assert result == [task1.id, task2.id]
  end

end
