defmodule CoursePlanner.TasksTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Tasks, Users}
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

  test "do not grab task when it has expired" do
    task = insert(:task, %{finish_time: Timex.now() |> Timex.shift(days: -1)})
    volunteer = insert(:volunteer)
    {:error, changeset} = Tasks.grab(task.id, volunteer.id, Timex.now())
    assert changeset.errors == [finish_time: {"is already finished, can't grab.", []}]
  end

  test "do not list finished tasks" do
    volunteer = insert(:volunteer)
    insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: -1)})
    task = insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: 1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
    [applicable_task] = Tasks.get_for_user(volunteer.id, Timex.now())
    assert applicable_task.id == task.id
  end

  test "do not list expired tasks" do
    volunteer = insert(:volunteer)
    insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: -1)})
    insert(:task, %{user_id: volunteer.id, finish_time: Timex.now() |> Timex.shift(hours: 1)})
    insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: -1)})
    task = insert(:task, %{finish_time: Timex.now() |> Timex.shift(hours: 1)})
    [applicable_task] = Tasks.get_unassigned(Timex.now())
    assert applicable_task.id == task.id
  end

  test "do not grab task that is already assigned" do
    volunteer1 = insert(:volunteer)
    volunteer2 = insert(:volunteer)
    task = insert(:task, %{user_id: volunteer1.id})
    {:error, changeset} = Tasks.grab(task.id, volunteer2.id, ~N[2017-01-01 02:00:00])
    assert changeset.errors == [user_id: {"is already assigned, can't grab.", []}]
  end

end
