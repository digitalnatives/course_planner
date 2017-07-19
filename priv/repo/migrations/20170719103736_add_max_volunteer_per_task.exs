defmodule CoursePlanner.Repo.Migrations.AddMaxVolunteerPerTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :user_id
      add :max_volunteer, :integer
      add :user_id, references(:users, on_delete: :nilify_all)
    end
    create index(:tasks, [:user_id])
  end
end
