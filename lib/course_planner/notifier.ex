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

  @spec notify_user(User, atom(), String.t) :: GenServer.cast
  def notify_user(%User{} = user, notification_type, path \\ "/") do
    GenServer.cast(__MODULE__, {:send, user, notification_type, path})
  end

  @spec handle_cast({atom(), User, atom(), String.t}, any()) :: {:noreply, any()}
  def handle_cast({:send, user, notification_type, path}, state) do
    email = UserEmail.build_email(user, notification_type, path)
    case Mailer.deliver(email) do
      {:ok, _} ->
        {:noreply, state}
      {:error, reason} ->
        Logger.error("Email delivery failed: #{reason}")
        {:noreply, [{:error, reason, email} | state]}
    end
  end
  def handle_cast(_, state), do: {:noreply, state}

  @doc """
  This function is used to suppress unhandled message warnings from `Swoosh.Adapters.Test` during unit tests
  """
  @spec handle_info(any(), any()) :: {:noreply, any()}
  def handle_info(_, state), do: {:noreply, state}
end
