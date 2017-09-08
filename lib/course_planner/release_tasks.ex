defmodule CoursePlanner.ReleaseTasks do

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  def myapp do
    {:ok, app} = Application.get_application(__MODULE__)
    app
  end

  def repos, do: Application.get_env(myapp(), :ecto_repos, [])

  def seed do
    me = myapp()

    IO.puts "Loading #{me}.."
    # Load the code for myapp, but don't start it
    :ok = Application.load(me)

    IO.puts "Starting dependencies.."
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for myapp
    IO.puts "Starting repos.."
    Enum.each(repos(), &(&1.start_link(pool_size: 1)))

    # Run migrations
    migrate()

    # Run the seed script if it exists
    seed_script = Path.join([priv_dir(:myapp), "repo", "seeds.exs"])
    if File.exists?(seed_script) do
      IO.puts "Running seed script.."
      Code.eval_file(seed_script)
    end

    # Signal shutdown
    IO.puts "Success!"
    :init.stop()
  end

  def migrate, do: Enum.each(repos(), &run_migrations_for/1)

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts "Running migrations for #{app}"
    Ecto.Migrator.run(repo, migrations_path(app), :up, all: true)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
  defp seed_path(app), do: Path.join([priv_dir(app), "repo", "seeds.exs"])


end
