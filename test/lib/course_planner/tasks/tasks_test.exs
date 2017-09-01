defmodule CoursePlanner.TasksTest do
  use CoursePlannerWeb.ModelCase

  alias CoursePlanner.{Tasks, Tasks.Task}
  import CoursePlanner.Factory

  describe "task sorting functionality when" do
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

  describe "listing of available tasks" do
    test "does not return past tasks" do
      volunteer = insert(:volunteer)
      insert(:task, %{volunteers: [volunteer], finish_time: Timex.now() |> Timex.shift(hours: -1)})
      insert(:task, %{volunteers: [volunteer], finish_time: Timex.now() |> Timex.shift(hours: 1)})
      insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
      task = insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
      [applicable_task] = Tasks.get_availables(nil, volunteer.id, Timex.now())
      assert applicable_task.id == task.id
    end

    test "does not return tasks with max_volunteers reached" do
      [volunteer1 | rest_volunteers] = insert_list(3, :volunteer)
      task1 = insert(:task, %{max_volunteers: 3, volunteers: rest_volunteers})
      task2 = insert(:task, %{max_volunteers: 3, volunteers: rest_volunteers})
      insert(:task, %{max_volunteers: 2, volunteers: rest_volunteers})

      applicable_task = Tasks.get_availables(nil, volunteer1.id, Timex.now())
      assert applicable_task == [task1, task2]
    end

    test "does not return tasks which are already grabbed by the volunteer" do
      [volunteer1 | rest_volunteers] = insert_list(3, :volunteer)
      task1 = insert(:task, %{max_volunteers: 3, volunteers: rest_volunteers})
      insert(:task, %{max_volunteers: 3, volunteers: [volunteer1]})
      insert(:task, %{max_volunteers: 2, volunteers: rest_volunteers})

      applicable_task = Tasks.get_availables(nil, volunteer1.id, Timex.now())
      assert applicable_task == [task1]
    end

    test "does not return if max_volunteers is surpassed" do
      [volunteer1, volunteer2, volunteer3] = insert_list(3, :volunteer)
      insert(:task, max_volunteers: 1, volunteers: [volunteer1, volunteer2])
      task2 = insert(:task, max_volunteers: 3, volunteers: [volunteer1, volunteer2])

      [applicable_task] = Tasks.get_availables(nil, volunteer3.id, Timex.now())
      assert applicable_task.id == task2.id
    end
  end

  describe "listing of volunteer's past tasks" do
    test "list past task based on their finished_time" do
      volunteer = insert(:volunteer)
      task1 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 1, hours: 1), volunteers: [volunteer]})
      task2 = insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 2, hours: 2), volunteers: [volunteer]})
      insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 2, hours: 8), volunteers: [volunteer]})
      insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 3, hours: 2), volunteers: [volunteer]})
      result = Tasks.get_past(nil, volunteer.id, Timex.shift(Timex.now(), days: 2, hours: 2)) |> Enum.map(&(&1.id))
      assert result == [task1.id, task2.id]
    end

    test "does not return past tasks which are not assigned to the volunteer" do
      volunteer = insert(:volunteer)
      insert_list(5, :task)
      assert [] == Tasks.get_past(nil, volunteer.id, Timex.shift(Timex.now(), days: 10))
    end

    test "return even if max_volunteers is surpassed" do
      [volunteer1, volunteer2] = insert_list(2, :volunteer)
      task = insert(:task, max_volunteers: 1, volunteers: [volunteer1, volunteer2])

      [applicable_task] = Tasks.get_past(nil, volunteer1.id, Timex.shift(Timex.now(), days: 20))
      assert length(applicable_task.volunteers) > applicable_task.max_volunteers
      assert applicable_task.id == task.id
    end
  end

  describe "listing of current volunteer's tasks" do
    test "does not return past tasks" do
      volunteer = insert(:volunteer)
      insert(:task, %{volunteers: [volunteer], finish_time: Timex.shift(Timex.now(), days: 1, hours: 1)})
      task = insert(:task, %{volunteers: [volunteer], finish_time: Timex.shift(Timex.now(), days: 1, hours: 2)})
      [applicable_task] = Tasks.get_for_user(nil, volunteer.id, Timex.shift(Timex.now(), days: 1, hours: 1))
      assert applicable_task.id == task.id
    end

    test "does not return not assigned tasks" do
      volunteer = insert(:volunteer)
      task = insert(:task, %{volunteers: [volunteer], finish_time: Timex.shift(Timex.now(), days: 1, hours: 2)})
      insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 1, hours: 2)})
      insert(:task, %{finish_time: Timex.shift(Timex.now(), days: 1, hours: 2)})
      [applicable_task] = Tasks.get_for_user(nil, volunteer.id, Timex.now())
      assert applicable_task.id == task.id
    end

    test "return even if max_volunteers is surpassed" do
      [volunteer1, volunteer2] = insert_list(2, :volunteer)
      task =  insert(:task, max_volunteers: 1, volunteers: [volunteer1, volunteer2])


      [applicable_task] = Tasks.get_for_user(nil, volunteer1.id, Timex.now())
      assert length(applicable_task.volunteers) > applicable_task.max_volunteers
      assert applicable_task.id == task.id
    end
  end
end
