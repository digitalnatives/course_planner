defimpl Canada.Can, for: CoursePlanner.User do
  alias CoursePlanner.{
    Tasks.Task, Terms.Term, User, Course, Class, AttendanceController, OfferedCourseController
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

  def can?(%User{role: "Volunteer", id: id}, :show, %Task{user_id: id}), do: true
  def can?(%User{role: "Volunteer"}, :index, Task), do: true
  def can?(%User{role: "Volunteer"}, :grab, %Task{user_id: nil}), do: true
  def can?(%User{role: "Volunteer"}, :show, %Task{user_id: nil}), do: true
  def can?(%User{role: "Volunteer"}, _, Task), do: false
  def can?(%User{role: "Volunteer"}, _, %Task{}), do: false

  def can?(_, _, _), do: true
end
