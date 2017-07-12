defmodule CoursePlanner.TasksTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Tasks, Volunteers, Users, Tasks.Task}
  import CoursePlanner.Factory

  @valid_task %{name: "some content", start_time: Timex.now(), finish_time: Timex.now()}
  @volunteer %{
    name: "Test Volunteer",
    email: "volunteer@courseplanner.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Volunteer"}

  test "assign volunteer to task" do
    {:ok, task} = Tasks.new(@valid_task)
    {:ok, volunteer} = Volunteers.new(@volunteer, "whatever")
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

end
