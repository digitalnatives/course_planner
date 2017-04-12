use Mix.Config

config :course_planner,
  ecto_repos: [CoursePlanner.Repo]

config :course_planner, CoursePlanner.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ml1LamAwEl2ra/9mM5mMbFffEqgL0vp05nbPjrXw0Mfzn0RO4x/t77NVPuZ5AzN+",
  render_errors: [view: CoursePlanner.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CoursePlanner.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: CoursePlanner.User,
  repo: CoursePlanner.Repo,
  module: CoursePlanner,
  logged_out_url: "/",
  title: "Course Planner",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :invitable]

config :coherence, CoursePlanner.Coherence.Mailer,
  adapter: Swoosh.Adapters.Local
# %% End Coherence Configuration %%

import_config "#{Mix.env}.exs"
