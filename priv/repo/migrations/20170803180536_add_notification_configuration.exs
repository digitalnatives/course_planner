defmodule CoursePlanner.Repo.Migrations.AddNotificationConfiguration do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :notified_at, :naive_datetime
      add :notification_period_days, :integer, null: false, default: 1
    end
  end

  def down do
    alter table(:users) do
      remove :notified_at
      remove :notification_period_days
    end
  end
end
