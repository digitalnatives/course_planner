defmodule CoursePlanner.Repo.Migrations.CreateEventsUsers do
  use Ecto.Migration

  def change do
    create table(:events_users, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false
    end

    create index(:events_users, [:user_id])
    create index(:events_users, [:event_id])
  end
end
