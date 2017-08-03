defmodule CoursePlanner do
  @moduledoc """
  This is the main module of the app
  """
  use Application
  alias CoursePlanner.{Endpoint, Repo, Notifier, Scheduler}

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Repo, []),
      supervisor(Endpoint, []),
      worker(Notifier, []),
      worker(Scheduler, []),
    ]

    opts = [strategy: :one_for_one, name: CoursePlanner.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
