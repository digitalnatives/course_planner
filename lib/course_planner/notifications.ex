defmodule CoursePlanner.Notifications do
  @moduledoc """
  Contains notification logic
  """

  alias CoursePlanner.{User, Notification, Notifier, Repo}
  import Ecto.Query

  def new, do: %Notification{}

  def type(%Notification{} = notification, type) when is_atom(type),
    do: %{notification | type: to_string(type)}

  def resource_path(%Notification{} = notification, path) when is_binary(path),
    do: %{notification | resource_path: path}

  def to(%Notification{} = notification, %User{} = user),
    do: %{notification | user: user}

  def send_all_notifications do
    Timex.today()
    |> get_notifiable_users()
    |> Enum.each(&Notifier.notify_all/1)
  end

  def get_notifiable_users(date) do
    User
    |> where([u],
      fragment("? + ?", u.notified_at, u.notification_period_days) <= type(^date, Ecto.Date))
    |> Repo.all()
    |> Repo.preload(:notifications)
  end

end
