defmodule CoursePlanner.Events do
  @moduledoc """
  Context for Events and relationship with Users.
  """

  import Ecto.Query, warn: false
  alias CoursePlanner.Repo
  alias Ecto.Changeset

  alias CoursePlanner.Events.Event
  alias CoursePlanner.Accounts.Users

  def all do
    Event
    |> Repo.all()
    |> Repo.preload(:users)
  end

  def get(id) do
    case Repo.get(Event, id) do
      nil -> {:error, :not_found}
      event -> {:ok, event |> Repo.preload(:users)}
    end
  end

  def create(attrs \\ %{}) do
    users = get_users(attrs)

    %Event{}
    |> Event.changeset(attrs)
    |> Changeset.put_assoc(:users, users)
    |> Repo.insert()
  end

  defp get_users(%{"user_ids" => ids}), do: Users.get(ids)
  defp get_users(_), do: []

  def update(%Event{} = event, attrs) do
    users = get_users(attrs)

    event
    |> Event.changeset(attrs)
    |> Changeset.put_assoc(:users, users)
    |> Repo.update()
  end

  def delete(%Event{} = event), do: Repo.delete(event)

  def change(%Event{} = event), do: Event.changeset(event, %{})
end
