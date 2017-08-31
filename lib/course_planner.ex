defmodule CoursePlanner do
  @moduledoc """
  This is the main module of the app
  """
  use Application
  alias CoursePlanner.{Repo, Notifier, NotifierScheduler}
  alias CoursePlannerWeb.Endpoint

  def start(_type, _args) do
    IO.inspect "hello!"
    IO.inspect "hello!"
    IO.inspect "hello!"
    IO.inspect "hello!"
    IO.inspect "hello!"
    IO.inspect "hello!"
    IO.inspect "hello!"
    import Supervisor.Spec

    children = [
      supervisor(Repo, []),
      supervisor(Endpoint, []),
      worker(Notifier, []),
      worker(NotifierScheduler, []),
    ]

    opts = [strategy: :one_for_one, name: CoursePlanner.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
