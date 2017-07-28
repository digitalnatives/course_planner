defmodule CoursePlanner.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def up do
    create table(:notifications) do
      add :type, :string
      add :resource_path, :string
      add :user_id, references(:users)

      timestamps()
    end

    create index(:notifications, [:user_id])
  end

  def down do
    drop table(:notifications)
  end
end
