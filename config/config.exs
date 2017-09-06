use Mix.Config

config :course_planner,
  ecto_repos: [CoursePlanner.Repo]

config :course_planner, CoursePlannerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ml1LamAwEl2ra/9mM5mMbFffEqgL0vp05nbPjrXw0Mfzn0RO4x/t77NVPuZ5AzN+",
  render_errors: [view: CoursePlannerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CoursePlanner.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :course_planner, CoursePlanner.Mailer,
  adapter: Swoosh.Adapters.Local

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: CoursePlanner.User,
  repo: CoursePlanner.Repo,
  module: CoursePlanner,
  web_module: CoursePlannerWeb,
  logged_out_url: "/",
  title: "Course Planner",
  layout: {CoursePlannerWeb.Coherence.LayoutView, "app.html"},
  messages_backend: CoursePlannerWeb.Coherence.Messages,
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token]

config :coherence, CoherenceDemo.Coherence.Mailer,
  adapter: Swoosh.Adapters.Local

config :coherence, CoursePlanner.Coherence.Mailer,
  adapter: Swoosh.Adapters.Local
# %% End Coherence Configuration %%

config :canary,
  repo: CoursePlanner.Repo,
  unauthorized_handler: {CoursePlannerWeb.Helper, :handle_unauthorized}

config :course_planner, CoursePlanner.NotifierScheduler,
  jobs: [
    {"0 18 * * *", {CoursePlanner.Notifications, :send_all_notifications, []}},
    {"30 17 * * *", {CoursePlanner.Notifications, :build_all_notifications, []}}
  ]

import_config "#{Mix.env}.exs"
