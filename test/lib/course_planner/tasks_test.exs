defmodule CoursePlanner.TasksTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Tasks, Tasks.Task}
  import CoursePlanner.Factory

  describe "tests tasks sorting functionality when" do
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
      task1 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 1)})
      task2 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 2)})
      task3 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 2, hours: 1)})
      result = Tasks.task_query("closest") |> Repo.all() |> Enum.map(&(&1.id))
      assert result == [task1.id, task2.id, task3.id]
    end
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
    task1 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 1, hours: 1), volunteers: [volunteer]})
    task2 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 2, hours: 2), volunteers: [volunteer]})
    insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 2, hours: 8), volunteers: [volunteer]})
    insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 3, hours: 2), volunteers: [volunteer]})
    result = Tasks.get_past(nil, volunteer.id, Timex.shift(Timex.now(), days: 2, hours: 2)) |> Enum.map(&(&1.id))
    assert result == [task1.id, task2.id]
  end

end
