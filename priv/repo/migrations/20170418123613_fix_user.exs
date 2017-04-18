defmodule CoursePlanner.Repo.Migrations.FixUser do
  use Ecto.Migration

  def change do
    rename table(:users), :first_name, to: :name

  end
end
