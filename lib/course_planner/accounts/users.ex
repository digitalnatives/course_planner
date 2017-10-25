defmodule CoursePlanner.Accounts.Users do
  @moduledoc """
    Handle all interactions with Users, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.{Repo, Accounts.User, Notifications.Notification, Notifications, Auth.Helper}
  alias Ecto.{DateTime, Changeset, Multi}
  alias Timex.Comparable
  alias Comeonin.Bcrypt

  import Ecto.Query

  @notifier Application.get_env(:course_planner, :notifier, CoursePlanner.Notifications.Notifier)

  defp auth_password_reset_token_validation_days,
    do: Application.get_env(:course_planner, :auth_password_reset_token_validation_days)

  def all do
    Repo.all(User)
  end

  def add_default_password_params(user, token) do
    random_default_password = Helper.get_random_token_with_length(12)

    user
    |> Map.put_new("reset_password_token", token)
    |> Map.put_new("reset_password_sent_at", DateTime.utc())
    |> Map.put_new("password", random_default_password)
    |> Map.put_new("password_confirmation", random_default_password)
  end

  def new_user(user, token) do
    updated_user = add_default_password_params(user, token)

    %User{}
    |> User.changeset(updated_user, :create)
    |> Repo.insert()
  end

  def get(ids) when is_list(ids) do
    Repo.all(from u in User, where: u.id in ^ids)
  end
  def get(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def delete(id, current_user_id \\ "") do
    if to_string(id) == to_string(current_user_id) do
      {:error, :self_deletion}
    else
      do_delete(id)
    end
  end

  defp do_delete(id) do
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

  def reset_password_token_valid?(%User{reset_password_sent_at: nil}), do: false
  def reset_password_token_valid?(user) do
    current_datetime = Timex.now()
    reset_password_sent_at = user.reset_password_sent_at

    days_since_reset_token_sent =
      Comparable.diff(current_datetime, reset_password_sent_at, :days)

    auth_password_reset_token_validation_days() >= days_since_reset_token_sent
  end

  def get_new_password_reset_token(user) do
    if reset_password_token_valid?(user) do
      %{
        reset_password_token: user.reset_password_token,
        reset_password_sent_at: user.reset_password_sent_at
       }
    else
      %{
        reset_password_token: Helper.get_random_token_with_length(12),
        reset_password_sent_at: DateTime.utc()
       }
    end
  end

  def check_password(user, password) do
    cond do
      user && Bcrypt.checkpw(password, user.password_hash) -> {:ok, :login}

      user -> {:error, :unauthorized}

      true -> Bcrypt.dummy_checkpw()
        {:error, :not_found}
    end
  end

  def update_login_fields(user, login_successful) do
    update_params =
      case login_successful do
        true -> %{last_sign_in_at: DateTime.utc(), failed_attempts: 0}
        false -> %{failed_attempts: user.failed_attempts + 1}
      end

    user
    |> User.changeset(update_params)
    |> Repo.update()
  end
end
