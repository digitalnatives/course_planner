defmodule CoursePlanner.Notifier do
  @moduledoc """
  Module responsible for notifying users through e-mail with changes
  """
  use GenServer
  alias CoursePlanner.{Mailer, Mailer.UserEmail, Notification, Repo, User, Users}
  require Logger

  @spec start_link :: GenServer.start_link
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec notify_user(Notification.t) :: GenServer.cast
  def notify_user(%Notification{} = notification) do
    GenServer.cast(__MODULE__, {:send_email, notification})
  end

  @spec notify_later(Notification.t) :: GenServer.cast
  def notify_later(%Notification{} = notification) do
    GenServer.cast(__MODULE__, {:save_email, notification})
  end

  @spec notify_all(User.t) :: GenServer.cast
  def notify_all(%User{notifications: []} = _user), do: :nothing
  def notify_all(%User{} = user) do
    GenServer.cast(__MODULE__, {:notify_all, user})
  end

  @spec handle_cast({atom(), Notification.t} | atom(), any()) :: {:noreply, any()}
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
  def handle_cast({:save_email, notification}, state) do
    changeset = Notification.changeset(notification)
    case Repo.insert(changeset) do
      {:ok, _} ->
        {:noreply, state}
      {:error, %{errors: errors, data: email}} ->
        Logger.error("Email saving failed: #{Kernel.inspect errors}")
        {:noreply, [{:error, errors, email} | state]}
    end
  end
  def handle_cast({:notify_all, user}, state) do
    email = UserEmail.build_summary(user)
    case Mailer.deliver(email) do
      {:ok, _} ->
        Users.update_notifications(user)
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
