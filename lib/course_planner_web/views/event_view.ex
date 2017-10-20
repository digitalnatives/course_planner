defmodule CoursePlannerWeb.EventView do
  @moduledoc false
  use CoursePlannerWeb, :view

  alias CoursePlanner.Accounts.Users
  alias Ecto.Changeset
  alias CoursePlannerWeb.SharedView

  def page_title, do: "Events"

  def selected_users(changeset) do
    changeset
    |> Changeset.get_field(:users)
    |> Enum.map(&(&1.id))
  end

  def all_users do
    Users.all()
    |> Enum.map(
        fn user ->
          full_name = SharedView.display_user_name(user)

          %{
            value: user.id,
            label: full_name,
            image: SharedView.get_gravatar_url(user.email)
          }
        end
      )
  end
end
