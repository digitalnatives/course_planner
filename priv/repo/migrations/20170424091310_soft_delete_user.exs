defmodule CoursePlanner.Repo.Migrations.SoftDeleteUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :deleted, :boolean
      add :deleted_at, :utc_datetime
    end
  end
end
