defimpl Canada.Can, for: CoursePlanner.User do
  alias CoursePlanner.{
    Terms.Term, User, Course, Class,
    AttendanceController, OfferedCourseController,
    SettingController, TaskController
  }

  def can?(%User{role: "Coordinator"}, _, _), do: true

  def can?(%User{role: role}, action, AttendanceController)
    when role in ["Teacher", "Coordinator"] and
         action in [:show, :index, :fill_course, :update_fill], do: true
  def can?(%User{role: "Student"}, action, AttendanceController)
    when action in [:show, :index], do: true
  def can?(_role, _action, AttendanceController), do: false

  def can?(%User{role: "Teacher"}, action, OfferedCourseController)
    when action in [:show, :edit, :update] , do: true
  def can?(%User{role: "Student"}, :show, OfferedCourseController), do: true
  def can?(_role, _action, OfferedCourseController), do: false

  def can?(_user, _action, ScheduleController), do: true

  def can?(%User{role: role}, _action, Term)
    when role in ["Teacher", "Student", "Volunteer"], do: false
  def can?(%User{role: role}, _action, %Term{})
    when role in ["Teacher", "Student", "Volunteer"], do: false

  def can?(%User{role: role}, _action, Class)
    when role in ["Teacher", "Student", "Volunteer"], do: false
  def can?(%User{role: role}, _action, %Class{})
   when role in ["Teacher", "Student", "Volunteer"], do: false

  def can?(%User{role: role}, _action, Course)
    when role in ["Teacher", "Student", "Volunteer"], do: false
  def can?(%User{role: role}, _action, %Course{})
    when role in ["Teacher", "Student", "Volunteer"], do: false

  def can?(%User{id: id}, action, %User{id: id})
    when action in [:show, :edit, :update], do: true
  def can?(%User{role: role}, _action, User)
    when role in ["Teacher", "Student", "Volunteer"], do: false
  def can?(%User{role: role}, _action, %User{})
    when role in ["Teacher", "Student", "Volunteer"], do: false

  def can?(_role, _action, SettingController), do: false

  def can?(%User{role: role}, _action, TaskController)
    when role in ["Teacher", "Student"], do: false
  def can?(%User{role: "Volunteer"}, action, TaskController)
    when action in [:show, :index, :grab], do: true
  def can?(%User{role: "Coordinator"}, :grab, TaskController), do: false

  def can?(_, _, _), do: true
end
