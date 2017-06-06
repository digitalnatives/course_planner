defimpl Canada.Can, for: CoursePlanner.User do
  alias CoursePlanner.{Tasks.Task, Terms.Term, User, Course}

  def can?(%User{role: "Coordinator"}, _, _), do: true

  def can?(%User{role: role}, _action, Term)
    when role in ["Teacher", "Student", "Volunteer"], do: false
  def can?(%User{role: role}, _action, %Term{})
    when role in ["Teacher", "Student", "Volunteer"], do: false

  def can?(%User{role: role}, _action, Course)
    when role in ["Teacher", "Student", "Volunteer"], do: false
  def can?(%User{role: role}, _action, %Course{})
    when role in ["Teacher", "Student", "Volunteer"], do: false

  def can?(%User{role: "Volunteer", id: id}, :show, %Task{user_id: id}), do: true
  def can?(%User{role: "Volunteer"}, :index, Task), do: true
  def can?(%User{role: "Volunteer"}, :grab, %Task{user_id: nil}), do: true
  def can?(%User{role: "Volunteer"}, :show, %Task{user_id: nil}), do: true
  def can?(%User{role: "Volunteer"}, _, Task), do: false
  def can?(%User{role: "Volunteer"}, _, %Task{}), do: false

  def can?(_, _, _), do: true
end
