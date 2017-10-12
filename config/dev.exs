use Mix.Config

config :course_planner, CoursePlannerWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/gulp/bin/gulp.js", "default", "watch",
                    cd: Path.expand("../assets", __DIR__)]]


config :course_planner, CoursePlannerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/course_planner_web/views/.*(ex)$},
      ~r{lib/course_planner_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :course_planner, CoursePlanner.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "course_planner_dev",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool_size: 10

config :course_planner,
  auth_email_from_name: "Dev Name",
  auth_email_from_email: "dev@email"
