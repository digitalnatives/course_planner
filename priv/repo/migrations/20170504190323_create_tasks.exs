defmodule CoursePlanner.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    execute("""
          CREATE TYPE task_status AS ENUM (
            'Pending',
            'Accomplished'
          )
    """)
    create table(:tasks) do
      add :name, :string
      add :deadline, :date
      add :status, :task_status
      add :user_id, references(:users)

      add :pending_at, :naive_datetime
      add :accomplished_at, :naive_datetime
      add :deleted_at, :naive_datetime

      timestamps()
    end
  end
end
