defmodule CoursePlannerWeb.TaskView do
  @moduledoc false
  use CoursePlannerWeb, :view
  alias CoursePlanner.Volunteers
  alias CoursePlannerWeb.SharedView
  alias Ecto.Changeset

  def get_task_volunteer_name_list(volunteers)
    when length(volunteers) != 0 do
      volunteers
      |> display_volunteer_name_list()
      |> text_to_html()
  end
  def get_task_volunteer_name_list(_volunteers), do: "No one"

  def page_title do
    "Tasks"
  end

  def display_volunteer_name_list(volunteers) do
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
