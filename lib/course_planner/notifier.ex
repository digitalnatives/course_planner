defmodule CoursePlanner.Notifier do
  @moduledoc """
  Module responsible for notifying users through e-mail with changes
  """
  use GenServer
  alias CoursePlanner.{Notification, User, Notifier.Server}
  require Logger

  @spec start_link :: GenServer.start_link
  def start_link do
    GenServer.start_link(Server, [], name: Server)
  end

  @spec notify_user(Notification.t) :: GenServer.cast
  def notify_user(%Notification{} = notification) do
    GenServer.cast(Server, {:send_email, notification})
  end

  @spec notify_later(Notification.t) :: GenServer.cast
  def notify_later(%Notification{} = notification) do
    GenServer.cast(Server, {:save_email, notification})
  end

  @spec notify_all(User.t) :: GenServer.cast
  def notify_all(%User{notifications: []} = _user), do: :nothing
  def notify_all(%User{} = user) do
    GenServer.cast(Server, {:notify_all, user})
  end

end
