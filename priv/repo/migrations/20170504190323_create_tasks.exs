defmodule CoursePlanner.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :start_time, :naive_datetime
      add :finish_time, :naive_datetime
      add :user_id, references(:users)

      add :pending_at, :naive_datetime
      add :accomplished_at, :naive_datetime
      add :deleted_at, :naive_datetime

      timestamps()
    end
  end
end
