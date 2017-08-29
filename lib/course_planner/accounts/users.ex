defmodule CoursePlanner.Accounts.Users do
  @moduledoc """
    Handle all interactions with Users, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.{Repo, Accounts.User, Notification, Notifications}
  alias Ecto.{DateTime, Changeset, Multi}

  import Ecto.Query

  @notifier Application.get_env(:course_planner, :notifier, CoursePlanner.Notifier)

  def all do
    Repo.all(User)
  end

  def new_user(user, token) do
    user =
      user
      |> Map.put_new("reset_password_token", token)
      |> Map.put_new("reset_password_sent_at", DateTime.utc())
      |> Map.put_new("password", "fakepassword")
      |> Map.put_new("password_confirmation", "fakepassword")

    User.changeset(%User{}, user)
  end

  def get(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def delete(id) do
    case get(id) do
      {:ok, user} -> Repo.delete(user)
      error -> error
    end
  end

  def notify_user(%{id: id}, %{id: id}, _, _), do: nil
  def notify_user(modified_user, _current_user, notification_type, path) do
    Notifications.new()
    |> Notifications.type(notification_type)
    |> Notifications.resource_path(path)
    |> Notifications.to(modified_user)
    |> @notifier.notify_later()
  end

  def update_notifications(user) do
    Multi.new()
    |> delete_notifications(user)
    |> mark_user_as_notified(user)
    |> Repo.transaction()
  end

  defp delete_notifications(multi, user) do
    notification_ids = Enum.map(user.notifications, &(&1.id))
    q = from n in Notification, where: n.id in ^notification_ids
    Multi.delete_all(multi, Notification, q)
  end

  defp mark_user_as_notified(multi, user) do
    Multi.update(multi, User, Changeset.change(user, notified_at: Ecto.DateTime.utc()))
  end

  def notify_all do
    User
    |> Repo.all()
    |> Repo.preload(:notifications)
    # credo:disable-for-next-line
    |> Enum.each(&@notifier.notify_all/1)
  end
end
