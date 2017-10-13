defmodule CoursePlanner.Mixfile do
  use Mix.Project

  def project do
    [app: :course_planner,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod or Mix.env == :heroku,
     start_permanent: Mix.env == :prod or Mix.env == :heroku,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env:
      [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {CoursePlanner, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :swoosh, :phoenix_swoosh, :quantum, :canada,
                    :canary, :elixir_make, :email_checker, :guardian, :comeonin,
                    :bcrypt_elixir, :timex, :timex_ecto]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:swoosh, "~> 0.7.0"},
     {:phoenix_swoosh, "~> 0.2.0"},
     {:canada, "~> 1.0.1"},
     {:canary, github: "cpjk/canary"},
     {:distillery, "~> 1.0.0"},
     {:dogma, "~> 0.1.0", only: [:dev, :test]},
     {:credo, "~> 0.7", only: [:dev, :test]},
     {:ex_machina, "~> 2.0", only: :test},
     {:excoveralls, "~> 0.6", only: :test},
     {:quantum, ">= 2.0.0-beta.1"},
     {:csv, "~> 2.0.0"},
     {:email_checker, "~> 0.1.1"},
     {:comeonin, "~> 4.0"},
     {:bcrypt_elixir, "~> 1.0"},
     {:guardian, "~> 0.14.5"},
     {:timex, "== 3.1.24"},
     {:timex_ecto, "== 3.1.1"}
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
