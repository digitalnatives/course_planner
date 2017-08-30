defmodule CoursePlanner.Repo.Migrations.CreateTaskUser do
  use Ecto.Migration

  def change do
    create table(:tasks_users, primary_key: false) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
    create index(:tasks_users, [:task_id])
    create index(:tasks_users, [:user_id])
  end
end
