defmodule CoursePlanner.PermissionsTest do
  use ExUnit.Case


  alias CoursePlanner.{
    Terms.Term,
    Accounts.User
  }
  alias CoursePlannerWeb.{
    AttendanceController,
    BulkController,
    CalendarController,
    ClassController,
    CoordinatorController,
    CourseController,
    CourseMatrixController,
    DashboardController,
    EventController,
    OfferedCourseController,
    PageController,
    ScheduleController,
    SettingController,
    StudentrController,
    SupervisorController,
    TaskController,
    TeacherController,
    TermController,
    UserController,
    VolunteerController,
  }

  @coordinator %User{
    email: "coordiantor@courseplanner.com",
    role: "Coordinator"
  }
  @supervisor %User{
    email: "supervisor@courseplanner.com",
    role: "Supervisor"
  }
  @volunteer %User{
    id: 2,
    email: "volunteer@courseplanner.com",
    role: "Volunteer"
  }
  @student %User{
    email: "student@courseplanner.com",
    role: "Student"
  }
  @teacher %User{
    email: "teacher@courseplanner.com",
    role: "Teacher"
  }

  Enum.map([:index, :show, :create, :update, :delete, :edit], fn action ->
    @action action
    test "coordinator can perform #{@action} in TaskController" do
        assert Canada.Can.can?(@coordinator, @action, TaskController)
    end
  end)

  for action <- [:index, :show], controller <- [
    AttendanceController,
    BulkController,
    CalendarController,
    ClassController,
    CoordinatorController,
    CourseController,
    CourseMatrixController,
    DashboardController,
    EventController,
    OfferedCourseController,
    PageController,
    ScheduleController,
    SettingController,
    StudentrController,
    SupervisorController,
    TaskController,
    TeacherController,
    TermController,
    UserController,
    VolunteerController] do

    @action action
    @controller controller
    test "supervisor can perform #{@action} in #{@controller}" do
      assert Canada.Can.can?(@supervisor, @action, @controller)
    end
  end

  for action <- [:create, :update, :delete, :edit], controller <- [
    AttendanceController,
    BulkController,
    ClassController,
    CoordinatorController,
    CourseController,
    CourseMatrixController,
    EventController,
    OfferedCourseController,
    SettingController,
    StudentrController,
    SupervisorController,
    TaskController,
    TeacherController,
    TermController,
    UserController,
    VolunteerController] do

    @action action
    @controller controller
    test "supervisor can perform #{@action} in #{@controller}" do
      refute Canada.Can.can?(@supervisor, @action, @controller)
    end
  end

  Enum.map([:index, :show, :grab], fn action ->
    @action action
    test "volunteer can perform #{@action} in TaskController" do
      assert Canada.Can.can?(@volunteer, @action, TaskController)
    end
  end)

  Enum.map([:create, :update, :delete, :edit], fn action ->
    @action action
    test "volunteer cannot perform #{@action} in TaskController" do
      refute Canada.Can.can?(@volunteer, @action, TaskController)
    end
  end)

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
