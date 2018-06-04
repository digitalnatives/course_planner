defmodule CoursePlanner.Events do
  @moduledoc """
  Context for Events and relationship with Users.
  """

  import Ecto.Query, warn: false

  alias CoursePlanner.{
    Accounts.Users,
    Events.Event,
    Notifications,
    Repo,
  }
  alias Ecto.Changeset

  @query from e in Event, order_by: [asc: e.date, asc: e.starting_time, asc: e.finishing_time]
  @notifier Application.get_env(:course_planner, :notifier, CoursePlanner.Notifications.Notifier)

  def all(%{role: role}) when role in ["Coordinator", "Supervisor"], do: Repo.all(@query)
  def all(user) do
    user
    |> Repo.preload(events: @query)
    |> Map.get(:events)
  end

  def all_splitted(now, current_user) do
    current_user
    |> all()
    |> Enum.split_with(&(compare_event_date_time(&1, now)))
    |> reverse_past_events()
  end

  def compare_event_date_time(event, now) do
    {:ok, event_datetime} = NaiveDateTime.new(event.date, event.starting_time)
    Timex.before?(event_datetime, now)
  end

  def reverse_past_events({past_events, upcoming_events}) do
    {Enum.reverse(past_events), upcoming_events}
  end

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

  def notify_new(event, current_user, path) do
    event
    |> Repo.preload(:users)
    |> Map.get(:users, [])
    |> Enum.reject(fn %{id: id} -> id == current_user.id end)
    |> Enum.each(&(notify_user(&1, event, :event_created, path)))
  end

  def notify_updated(users_before, event, current_user, path) do
    users_before =
      users_before
      |> Enum.reject(fn %{id: id} -> id == current_user.id end)

    users_after =
      event.users
      |> Enum.reject(fn %{id: id} -> id == current_user.id end)

    diff = List.myers_difference(users_before, users_after)

    diff
    |> Keyword.get(:del, [])
    |> notify_users(event, :event_uninvited, path)

    diff
    |> Keyword.get(:eq, [])
    |> notify_users(event, :event_updated, path)

    diff
    |> Keyword.get(:ins, [])
    |> notify_users(event, :event_created, path)
  end

  def notify_deleted(event, current_user) do
    users =
      event
      |> Repo.preload(:users)
      |> Map.get(:users)
      |> Enum.reject(fn %{id: id} -> id == current_user.id end)

    notify_users(users, event, :event_deleted, "/")
  end

  def notify_users(users, event, type, path) do
    users
    |> Enum.each(&(notify_user(&1, event, type, path)))
  end

  def notify_user(user, event, type, path) do
    Notifications.new()
    |> Notifications.type(type)
    |> Notifications.resource_path(path)
    |> Notifications.to(user)
    |> Notifications.add_data(%{event: event})
    |> @notifier.notify_later()
  end

end
