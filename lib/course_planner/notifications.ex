defmodule CoursePlanner.Notifications do
  @moduledoc """
  Contains notification logic
  """

  alias CoursePlanner.{User, Notification, Notifier, Repo}

  def new, do: %Notification{}

  def type(%Notification{} = notification, type) when is_atom(type),
    do: %{notification | type: to_string(type)}

  def resource_path(%Notification{} = notification, path) when is_binary(path),
    do: %{notification | resource_path: path}

  def to(%Notification{} = notification, %User{} = user),
    do: %{notification | user: user}

  def send_all_notifications do
    User
    |> Repo.all()
    |> Repo.preload(:notifications)
    |> Enum.each(&Notifier.notify_all/1)
  end

end
