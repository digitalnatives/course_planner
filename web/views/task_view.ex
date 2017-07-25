defmodule CoursePlanner.TaskView do
  @moduledoc false
  use CoursePlanner.Web, :view
  alias CoursePlanner.{SharedView, Volunteers}
  alias Ecto.Changeset

  def task_user(conn, task) do
    task.volunteers
    |> Enum.map(fn(volunteer) ->
         link volunteer.name, to: volunteer_path(conn, :show, volunteer)
       end)
  end
  def task_user(conn, task), do: "no one"

  def format_users(users) do
    [{"no one", 0} | Enum.map(users, &{&1.name, &1.id})]
  end

  def page_title do
    "Tasks"
  end

  def task_users(volunteers) do
    volunteers
    |> Enum.map(fn(volunteer) -> SharedView.display_user_name(volunteer) end)
    |> Enum.join("\n")
  end

  def selected_volunteers(changeset) do
    changeset
    |> Changeset.get_field(:volunteers)
    |> Enum.map(&(&1.id))
  end

  def volunteers_to_select do
    Volunteers.all()
    |> Enum.map(
        fn volunteer ->
          full_name = SharedView.display_user_name(volunteer)

          %{
            value: volunteer.id,
            label: full_name,
            image: SharedView.get_gravatar_url(volunteer.email)
          }
        end
      )
  end
end
