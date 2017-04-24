defmodule CoursePlanner.Repo.Migrations.CreateTerm do
  use Ecto.Migration

  def change do
    create table(:terms) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :holidays, {:array, :map}, default: []

      add :status, :entity_status
      add :planned_at, :naive_datetime
      add :activated_at, :naive_datetime
      add :froze_at, :naive_datetime
      add :finished_at, :naive_datetime
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
