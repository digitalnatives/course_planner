defmodule CoursePlanner.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def up do
    create table(:notifications) do
      add :type, :string, null: false
      add :resource_path, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notifications, [:user_id])
  end

  def down do
    drop table(:notifications)
  end
end
