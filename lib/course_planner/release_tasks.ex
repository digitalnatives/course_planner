defmodule CoursePlanner.ReleaseTasks do
  @moduledoc """
  Module containing the migration/seeds tasks
  They are supposed to run from `rel/commands/migrate.sh`
  and `rel/commands/setup.sh` before the application is started
  """
  alias Ecto.Migrator

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  def repos, do: Application.get_env(:course_planner, :ecto_repos, [])

  def prepare do
    IO.puts "Loading course_planner.."
    :ok = Application.load(:course_planner)

    IO.puts "Starting dependencies.."
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts "Starting repos.."
    Enum.each(repos(), &(&1.start_link(pool_size: 1)))
  end

  def setup do

    prepare()
    migrate()
    seed()

    IO.puts "Success!"
    :init.stop()
  end

  def migrate_and_stop do
    migrate()
    IO.puts "Success!"
    :init.stop()
  end

  def migrate do
    prepare()
    Enum.each(repos(), &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts "Running migrations for #{app}"
    Migrator.run(repo, migrations_path(app), :up, all: true)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])

  def seed do
    seed_script = seed_path(:course_planner)
    if File.exists?(seed_script) do
      IO.puts "Running seed script.."
      Code.eval_file(seed_script)
    end
  end

  defp seed_path(app), do: Path.join([priv_dir(app), "repo", "seeds.exs"])

  defp priv_dir(app), do: :code.priv_dir(app)

end
