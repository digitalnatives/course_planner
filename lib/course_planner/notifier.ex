defmodule CoursePlanner.Notifier do
  @moduledoc """
  Module responsible for notifying users through e-mail with changes
  """
  use GenServer
  alias CoursePlanner.{Mailer, Mailer.UserEmail, Notification}
  require Logger

  @spec start_link :: GenServer.start_link
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec notify_user(Notification.t) :: GenServer.cast
  def notify_user(%Notification{} = notification) do
    GenServer.cast(__MODULE__, {:send_email, notification})
  end

  @spec handle_cast({atom(), Notification.t}, any()) :: {:noreply, any()}
  def handle_cast({:send_email, notification}, state) do
    email = UserEmail.build_email(notification)
    case Mailer.deliver(email) do
      {:ok, _} ->
        {:noreply, state}
      {:error, reason} ->
        Logger.error("Email delivery failed: #{Kernel.inspect reason}")
        {:noreply, [{:error, reason, email} | state]}
    end
  end
  def handle_cast(_, state), do: {:noreply, state}

  @doc """
  This function is used to suppress unhandled message warnings from `Swoosh.Adapters.Test` during
  unit tests
  """
  @spec handle_info(any(), any()) :: {:noreply, any()}
  def handle_info(_, state), do: {:noreply, state}
end
