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

  def render("index.json", %{events: events}) do
    %{events: render_many(events, CoursePlannerWeb.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{
      name: event.name,
      description: event.description,
      location: event.location,

      date: event.date,
      starting_time: event.starting_time,
      finishing_time: event.finishing_time,
      users: Enum.map(event.users, &user_json/1)
    }
  end

  defp user_json(user) do
    %{
      name: user.name,
      family_name: user.family_name,
      nickname: user.nickname
    }
  end
end
