defmodule CoursePlanner.Notifications do
  @moduledoc """
  Contains notification logic
  """

  alias CoursePlanner.{User, Notification, Notifier, Repo, Settings, SystemVariable, OfferedCourses}
  import Ecto.Query

  def new, do: %Notification{}

  def type(%Notification{} = notification, type) when is_atom(type),
    do: %{notification | type: to_string(type)}

  def resource_path(%Notification{} = notification, path) when is_binary(path),
    do: %{notification | resource_path: path}

  def to(%Notification{} = notification, %User{} = user),
    do: %{notification | user: user}

  def add_data(%Notification{} = notification, data \\ %{}),
    do: %{notification | data: data}

  def wake_up(now \\ DateTime.utc_now) do
    executed_at = Settings.get_value("NOTIFICATION_JOB_EXECUTED_AT", now)
    if Timex.diff(now, executed_at, :days) >= 1 do
      build_all_notifications(now)
      send_all_notifications(now)
    end
  end

  def build_all_notifications(now \\ DateTime.utc_now) do
    if Settings.get_value("ENABLE_NOTIFICATION", true) do
      now
      |> get_notifiable_users()
      |> OfferedCourses.create_missing_attendance_notifications()
    end
  end

  def send_all_notifications(now \\ DateTime.utc_now, action \\ &Notifier.notify_all/1) do
    if Settings.get_value("ENABLE_NOTIFICATION", true) do
      now
      |> get_notifiable_users()
      |> Enum.each(action)

      update_executed_at(now)
    end
  end

  def get_notifiable_users(date) do
    User
    |> where([u],
      fragment("? + make_interval(days => ?)", u.notified_at, u.notification_period_days) <= ^date
      or is_nil(u.notified_at))
    |> Repo.all()
    |> Repo.preload(:notifications)
  end

  def update_executed_at(timestamp) do
    changeset =
      case Repo.get_by(SystemVariable, key: "NOTIFICATION_JOB_EXECUTED_AT") do
        nil -> new_executed_at(timestamp)
        executed_at -> updated_excuted_at(executed_at, timestamp)
      end
    Repo.insert_or_update!(changeset)
  end

  defp new_executed_at(timestamp) do
    SystemVariable.changeset(
      %SystemVariable{},
      %{
        key: "NOTIFICATION_JOB_EXECUTED_AT",
        value: DateTime.to_iso8601(timestamp),
        type: "utc_datetime",
        required: true,
        visible: false,
        editable: true
      })
  end

  defp updated_excuted_at(executed_at, timestamp) do
    SystemVariable.changeset(
      executed_at,
      %{
        value: DateTime.to_iso8601(timestamp),
        type: "utc_datetime"
      },
      :update)
  end

  def create_simple_notification(%{type: type, user: user, path: path, data: data}) do
    new()
    |> type(type)
    |> resource_path(path)
    |> to(user)
    |> add_data(data)
  end
end
