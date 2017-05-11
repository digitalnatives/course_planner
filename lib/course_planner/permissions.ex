defimpl Canada.Can, for: CoursePlanner.User do
  alias CoursePlanner.User
  alias CoursePlanner.Tasks.Task

  def can?(%User{role: "Coordinator"}, _, %Task{}), do: true
  def can?(%User{role: "Volunteer", id: id}, :done, %Task{user_id: id}), do: true
  def can?(%User{role: "Volunteer"}, action, %Task{user_id: nil})
    when action in [:index, :show, :grab], do: true
  def can?(%User{role: "Volunteer"}, action, %Task{user_id: nil})
    when action in [:create, :update, :delete, :edit, :done], do: false
  def can?(%User{role: "Volunteer"}, _, %Task{}), do: false
end
