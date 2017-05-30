defmodule CoursePlanner.Notifier do
  @moduledoc """
  Module responsible for notifying users through e-mail with changes
  """
  use GenServer
  alias CoursePlanner.{User, Mailer, Mailer.UserEmail}
  require Logger

  defmodule Notification do
    @moduledoc "Notification struct to be used by Notifier"
    defstruct type: nil, resource_path: "/", to: nil

    def new, do: %Notification{}

    def type(%Notification{} = notification, type) when is_atom(type),
      do: %{notification | type: type}

    def resource_path(%Notification{} = notification, path) when is_binary(path),
      do: %{notification | resource_path: path}

    def to(%Notification{} = notification, %User{} = user),
      do: %{notification | to: user}
  end

  @spec start_link :: GenServer.start_link
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec notify_user(Notification.t) :: GenServer.cast
  def notify_user(%Notification{} = notification) do
    GenServer.cast(__MODULE__, {:send_email, notification})
  end

  @spec handle_cast({atom(), Notification.t}, any()) :: {:noreply, any()}
  def handle_cast({:send_email, %{to: user, type: type, resource_path: path}}, state) do
    email = UserEmail.build_email(user, type, path)
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
