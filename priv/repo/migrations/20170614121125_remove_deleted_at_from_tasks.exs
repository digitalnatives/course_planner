defmodule CoursePlanner.Repo.Migrations.RemoveStatusFromTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove  :user_id
      remove :deleted_at
      add :user_id, references(:users, on_delete: :nilify_all)
    end
  end
end
