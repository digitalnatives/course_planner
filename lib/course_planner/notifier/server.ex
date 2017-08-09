defmodule CoursePlanner.Notifier.Server do
  @moduledoc false
  use GenServer
  alias CoursePlanner.{Mailer, Mailer.UserEmail, Notification, Repo, Users}
  require Logger

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
