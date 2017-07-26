defmodule CoursePlanner.PermissionsTest do
  use ExUnit.Case

  alias CoursePlanner.{TaskController, Terms.Term, User}

  @coordinator %User{
    email: "valid@email",
    role: "Coordinator"
  }
  @volunteer %User{
    id: 2,
    email: "valid@email2",
    role: "Volunteer"
  }
  @student %User{
    email: "student@example.com",
    role: "Student"
  }
  @teacher %User{
    email: "teacher@example.com",
    role: "Teacher"
  }

  Enum.map([:index, :show, :create, :update, :delete, :edit], fn action ->
    @action action
    test "coordinator can perform #{@action} in Task" do
        assert Canada.Can.can?(@coordinator, @action, TaskController)
    end
  end)

  Enum.map([:show, :grab, :drop], fn action ->
    @action action
    test "volunteer can perform #{@action} in unassigned tasks" do
      assert Canada.Can.can?(@volunteer, @action, TaskController)
    end
  end)

  Enum.map([:create, :update, :delete, :edit], fn action ->
    @action action
    test "volunteer cannot perform #{@action} in unassigned tasks" do
      refute Canada.Can.can?(@volunteer, @action, TaskController)
    end
  end)

  test "volunteer can show its own tasks" do
    assert Canada.Can.can?(@volunteer, :show, TaskController)
  end

  test "volunteer can index tasks" do
    assert Canada.Can.can?(@volunteer, :index, TaskController)
  end

  for action <- [:index, :new, :create] do
    @action action
    test "coordinator can perform #{action} in Term" do
      assert Canada.Can.can?(@coordinator, @action, Term)
    end
  end

  for action <- [:show, :edit, :update, :delete] do
    @action action
    test "coordinator can perform #{action} in Term" do
      assert Canada.Can.can?(@coordinator, @action, %Term{})
    end
  end

  for action <- [:index, :new, :create],
        user <- [@volunteer, @student, @teacher] do
    @action action
    @user user
    test "#{user.role} can't perform #{action} in Term" do
      refute Canada.Can.can?(@user, @action, Term)
    end
  end

  for action <- [:show, :edit, :update, :delete],
        user <- [@volunteer, @student, @teacher] do
    @action action
    @user user
    test "#{user.role} can't perform #{action} in Term" do
      refute Canada.Can.can?(@user, @action, %Term{})
    end
  end
end
