defimpl Canada.Can, for: CoursePlanner.User do
  alias CoursePlanner.{
    AttendanceController,
    OfferedCourseController,
    ScheduleController,
    Tasks.Task,
    User,
  }

  def can?(%User{role: "Coordinator"}, _action, _controller), do: true

  def can?(%User{role: "Teacher"}, _action, AttendanceController), do: true
  def can?(%User{role: "Teacher"}, action, OfferedCourseController)
    when action in [:index, :show, :edit, :update], do: true

  def can?(%User{role: "Student"}, action, AttendanceController)
    when action in [:index, :show], do: true
  def can?(%User{role: "Student"}, action, OfferedCourseController)
    when action in [:index, :show], do: true

  def can?(%User{role: "Volunteer", id: id}, :show, %Task{user_id: id}), do: true
  def can?(%User{role: "Volunteer"}, :index, Task), do: true
  def can?(%User{role: "Volunteer"}, :grab, %Task{}), do: true
  def can?(%User{role: "Volunteer"}, :show, %Task{user_id: nil}), do: true

  def can?(_user, _action, ScheduleController), do: true

  def can?(%User{id: id}, action, %User{id: id})
    when action in [:show, :edit, :update], do: true

  def can?(_user, _action, _controller), do: false
end
