defmodule CoursePlanner.PermissionsTest do
  use ExUnit.Case

  alias CoursePlanner.User
  alias CoursePlanner.Tasks.Task

  @coordinator %User{
    email: "valid@email",
    role: "Coordinator"
  }
  @volunteer %User{
    id: 2,
    email: "valid@email2",
    role: "Volunteer"
  }

  Enum.map([:index, :show, :create, :update, :delete, :edit], fn action ->
    @action action
    test "coordinator can perform #{@action} in Task" do
        assert Canada.Can.can?(@coordinator, @action, %Task{})
    end
  end)

  Enum.map([:show, :grab], fn action ->
    @action action
    test "volunteer can perform #{@action} in unassigned tasks" do
      assert Canada.Can.can?(@volunteer, @action, %Task{user_id: nil})
    end
  end)

  Enum.map([:create, :update, :delete, :edit, :done], fn action ->
    @action action
    test "volunteer cannot perform #{@action} in unassigned tasks" do
      refute Canada.Can.can?(@volunteer, @action, %Task{user_id: nil})
    end
  end)

  test "volunteer can mark its own tasks as done" do
    assert Canada.Can.can?(@volunteer, :done, %Task{user_id: @volunteer.id})
  end

  test "volunteer can show its own tasks" do
    assert Canada.Can.can?(@volunteer, :show, %Task{user_id: @volunteer.id})
  end

  test "volunteer can index tasks" do
    assert Canada.Can.can?(@volunteer, :index, Task)
  end
end
