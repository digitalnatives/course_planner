use Mix.Config

config :course_planner,
  ecto_repos: [CoursePlanner.Repo],
  site_name: "CoursePlanner",
  auth_email_reply_to: nil,
  auth_email_title: "Course Planner"

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

config :canary,
  repo: CoursePlanner.Repo,
  unauthorized_handler: {CoursePlannerWeb.Helper, :handle_unauthorized}

config :course_planner, CoursePlanner.Notifications.NotifierScheduler,
  jobs: [
    {"0 18 * * *", {CoursePlanner.Notifications, :send_all_notifications, []}},
    {"30 17 * * *", {CoursePlanner.Notifications, :build_all_notifications, []}}
  ]

config :email_checker,
  validations: [EmailChecker.Check.Format]

import_config "#{Mix.env}.exs"

config :guardian, Guardian,
   issuer: "CoursePlanner.#{Mix.env}",
   ttl: {1, :days},
   verify_issuer: true,
   serializer: CoursePlanner.Auth.GuardianSerializer,
   secret_key: to_string(Mix.env) <> "SuPerseCret_aBraCadabrA"
