# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :course_planner,
  ecto_repos: [CoursePlanner.Repo]

# Configures the endpoint
config :course_planner, CoursePlanner.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ml1LamAwEl2ra/9mM5mMbFffEqgL0vp05nbPjrXw0Mfzn0RO4x/t77NVPuZ5AzN+",
  render_errors: [view: CoursePlanner.ErrorView, accepts: ~w(json)],
  pubsub: [name: CoursePlanner.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
