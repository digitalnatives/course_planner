defmodule CoursePlanner.TasksTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Tasks, Volunteers, Users}
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

  test "get unassigned tasks" do
    t1 = insert(:task)
    t2 = insert(:task)
    [new_t2, new_t1] = Tasks.get_unassigned_tasks()
    assert t1.id == new_t1.id
    assert t2.id == new_t2.id
  end

  test "get task for user" do
    volunteer = insert(:volunteer)
    t1 = insert(:task, %{user_id: volunteer.id})
    insert(:task)
    t2 = insert(:task, %{user_id: volunteer.id})
    [new_t2, new_t1] = Tasks.get_user_tasks(volunteer.id)
    assert t1.id == new_t1.id
    assert t2.id == new_t2.id
  end

end
