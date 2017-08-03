defmodule CoursePlanner.Repo.Migrations.AddNotificationConfiguration do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :notified, :date
      add :notification_frequency_days, :integer, null: false, default: 1
    end
  end

  def down do
    alter table(:users) do
      remove :notified
      remove :notification_frequency_days
    end
  end
end
