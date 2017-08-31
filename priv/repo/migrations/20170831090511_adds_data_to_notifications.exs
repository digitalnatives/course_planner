defmodule CoursePlanner.Repo.Migrations.AddsDataToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :data, :map
    end
  end
end
