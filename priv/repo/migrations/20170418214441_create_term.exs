defmodule CoursePlanner.Repo.Migrations.CreateTerm do
  use Ecto.Migration

  def change do
    create table(:terms) do
      add :name, :string
      add :starting_day, :date
      add :finishing_day, :date
      add :holidays, {:array, :date}
      add :status, :string
      add :frozen_at, :utc_datetime
      add :finished_at, :utc_datetime
      add :deleted_at, :utc_datetime

      timestamps()
    end

  end
end
