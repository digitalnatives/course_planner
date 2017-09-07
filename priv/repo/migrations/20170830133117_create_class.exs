defmodule CoursePlanner.Repo.Migrations.CreateClass do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :date, :date
      add :starting_at, :time
      add :finishes_at, :time
      add :classroom, :string

      timestamps()
    end
  end
end
