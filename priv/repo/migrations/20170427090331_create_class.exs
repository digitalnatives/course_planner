defmodule CoursePlanner.Repo.Migrations.CreateClass do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :date, :date
      add :starting_at, :time
      add :finishes_at, :time
      add :status, :entity_status
      add :deleted_at, :naive_datetime
      add :course_id, references(:courses, on_delete: :delete_all)

      timestamps()
    end
    create index(:classes, [:course_id])

  end
end
