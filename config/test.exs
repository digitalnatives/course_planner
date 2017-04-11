use Mix.Config

config :course_planner, CoursePlanner.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :course_planner, CoursePlanner.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "course_planner_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  config :course_planner, CoursePlanner.Mailer.Main,
    adapter: Swoosh.Adapters.Test
