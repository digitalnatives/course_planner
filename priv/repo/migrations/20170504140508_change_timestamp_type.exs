defmodule CoursePlanner.Repo.Migrations.ChangeTimestampType do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :deleted_at
      remove :active_at
      remove :frozen_at
      remove :graduated_at
    end

    alter table(:users) do
      add :deleted_at, :naive_datetime
      add :active_at, :naive_datetime
      add :frozen_at, :naive_datetime
      add :graduated_at, :naive_datetime
    end
  end
end
