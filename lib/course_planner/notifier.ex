defmodule CoursePlanner.Notifier do
  @moduledoc """
  Module responsible for notifying users through e-mail with changes
  """
  use GenServer
  alias CoursePlanner.{User, Mailer, Mailer.UserEmail}
  require Logger

  @spec start_link :: GenServer.start_link
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec notify_user(User, atom()) :: GenServer.cast
  def notify_user(%User{} = user, notification_type) do
    GenServer.cast(__MODULE__, {:send, user, notification_type})
  end

  @spec handle_cast({atom(), User, atom()}, any()) :: {:noreply, any()}
  def handle_cast({:send, user, notification_type}, state) do
    email = UserEmail.build_email(user, notification_type)
    case Mailer.deliver(email) do
      {:ok, _} ->
        {:noreply, state}
      {:error, reason} ->
        Logger.error("Email delivery failed: #{reason}")
        {:noreply, [{:error, reason, email} | state]}
    end
  end

  @spec handle_info(any(), any()) :: {:noreply, any()}
  def handle_info(_, state), do: {:noreply, state}
end
