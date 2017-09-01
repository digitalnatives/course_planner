defmodule CoursePlanner.TestNotifier do

  alias CoursePlanner.{Notification, Notifier.Server}

  def notify_user(_), do: :ok
  def notify_later(%Notification{} = notification) do
    Server.handle_cast({:save_email, notification}, "test")
  end
  def notify_all(_), do: :ok
end
