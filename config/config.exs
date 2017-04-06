use Mix.Config

config :course_planner,
  ecto_repos: [CoursePlanner.Repo]

config :course_planner, CoursePlanner.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ml1LamAwEl2ra/9mM5mMbFffEqgL0vp05nbPjrXw0Mfzn0RO4x/t77NVPuZ5AzN+",
  render_errors: [view: CoursePlanner.ErrorView, accepts: ~w(json)],
  pubsub: [name: CoursePlanner.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
