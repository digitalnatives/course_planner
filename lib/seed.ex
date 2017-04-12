defmodule Mix.Tasks.CoursePlanner.Seed do
  use Mix.Task
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto

  def run(_) do
    Mix.Task.run "app.start", []
    seed(Mix.env)
  end

  def seed(:dev) do
    User.changeset(%User{}, %{name: "Test User", email: "testuser@example.com", password: "secret", password_confirmation: "secret"})
      |> Repo.insert!
  end

  def seed(:prod) do
  end
end
