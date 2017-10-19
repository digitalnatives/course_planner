defmodule CoursePlanner.Events do
  @moduledoc """
  Context for Events and relationship with Users.
  """

  import Ecto.Query, warn: false

  alias CoursePlanner.{
    Accounts.Users,
    Events.Event,
    Repo,
  }
  alias Ecto.Changeset

  def all, do: Repo.all(Event)

  def all_with_users, do: Repo.preload(all(), :users)

  def get(id) do
    case Repo.get(Event, id) do
      nil -> {:error, :not_found}
      event -> {:ok, Repo.preload(event, :users)}
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
    |> Repo.preload(:users)
    |> Event.changeset(attrs)
    |> Changeset.put_assoc(:users, users)
    |> Repo.update()
  end

  def delete(%Event{} = event), do: Repo.delete(event)

  def change(%Event{} = event), do: Event.changeset(event, %{})
end