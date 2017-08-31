use Mix.Config

config :course_planner, CoursePlannerWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "${ENDPOINT_URL_HOST}", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: "${SECRET_KEY_BASE}"

config :logger, level: :info

config :course_planner, CoursePlanner.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},

  # TODO: make this configurable by env var again.
  pool_size: 10,
  ssl: true

config :coherence, CoursePlannerWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}

config :coherence,
  email_from_name: "${EMAIL_FROM_NAME}",
  email_from_email: "${EMAIL_FROM_EMAIL}"

config :course_planner, CoursePlanner.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}
