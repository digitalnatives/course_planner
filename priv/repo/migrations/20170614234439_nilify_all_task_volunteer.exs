defmodule CoursePlanner.Repo.Migrations.NilifyAllTaskVolunteer do
  use Ecto.Migration

  def change do
    drop_if_exists index(:tasks, [:user_id])
    alter table(:tasks) do
      modify :user_id, references(:users, on_delete: :nilify_all)
    end
  end
end
