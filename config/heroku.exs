use Mix.Config

config :course_planner, CoursePlannerWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: System.get_env("ENDPOINT_URL_HOST"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :logger, level: :info

config :course_planner, CoursePlanner.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :course_planner, CoursePlanner.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

config :course_planner,
  auth_email_from_name: "${EMAIL_FROM_NAME}",
  auth_email_from_email: "${EMAIL_FROM_EMAIL}"

config :recaptcha,
  secret: "${RECAPTCHA_SECRET_KEY}",
  public_key: "${RECAPTCHA_SITE_KEY}"
