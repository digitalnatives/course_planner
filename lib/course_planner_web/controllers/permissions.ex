defimpl Canada.Can, for: CoursePlanner.Accounts.User do

  alias CoursePlanner.Accounts.User
  alias CoursePlannerWeb.{
    AttendanceController,
    CalendarController,
    DashboardController,
    EventController,
    OfferedCourseController,
    PageController,
    ScheduleController,
    TaskController,
  }

  def can?(%User{role: "Coordinator"}, action, TaskController)
    when action in [:grab, :drop], do: false

  def can?(%User{role: "Coordinator"}, _action, _controller), do: true

  def can?(%User{role: "Teacher"}, _action, AttendanceController), do: true
  def can?(%User{role: "Teacher"}, action, OfferedCourseController)
    when action in [:index, :show, :edit, :update], do: true

  def can?(%User{role: "Student"}, action, AttendanceController)
    when action in [:index, :show], do: true
  def can?(%User{role: "Student"}, action, OfferedCourseController)
    when action in [:index, :show], do: true

  def can?(%User{role: "Volunteer"}, action, TaskController)
    when action in [:index, :show, :grab, :drop], do: true

  def can?(_user, _action, CalendarController), do: true
  def can?(_user, _action, DashboardController), do: true
  def can?(_user, _action, PageController), do: true
  def can?(_user, _action, ScheduleController), do: true

  def can?(%User{id: id}, action, %User{id: id})
    when action in [:show, :edit, :update], do: true

  def can?(_user, action, EventController)
    when action in [:index, :show, :fetch], do: true

  def can?(_user, _action, _controller), do: false
end
