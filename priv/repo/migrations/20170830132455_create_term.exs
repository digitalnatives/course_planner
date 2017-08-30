defmodule CoursePlanner.Repo.Migrations.CreateTerm do
  use Ecto.Migration

  def change do
    create table(:terms) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :holidays, {:array, :map}, default: []
      add :minimum_teaching_days, :integer, null: false, default: 1

      timestamps()
    end
  end
end
