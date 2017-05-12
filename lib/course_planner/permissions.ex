defimpl Canada.Can, for: CoursePlanner.User do
  alias CoursePlanner.User
  alias CoursePlanner.Tasks.Task

  def can?(%User{role: "Coordinator"}, _, _), do: true
  def can?(%User{role: "Volunteer", id: id}, :done, %Task{user_id: id}), do: true
  def can?(%User{role: "Volunteer", id: id}, :show, %Task{user_id: id}), do: true
  def can?(%User{role: "Volunteer"}, :index, Task), do: true
  def can?(%User{role: "Volunteer"}, :grab, %Task{user_id: nil}), do: true
  def can?(%User{role: "Volunteer"}, :show, %Task{user_id: nil}), do: true
  def can?(%User{role: "Volunteer"}, _, Task), do: false
  def can?(%User{role: "Volunteer"}, _, %Task{}), do: false
  def can?(_, _, _), do: true
end
