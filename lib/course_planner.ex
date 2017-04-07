defmodule CoursePlanner do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(CoursePlanner.Repo, []),
      supervisor(CoursePlanner.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: CoursePlanner.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CoursePlanner.Endpoint.config_change(changed, removed)
    :ok
  end
end
