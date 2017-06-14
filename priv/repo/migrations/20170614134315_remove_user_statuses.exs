defmodule CoursePlanner.Repo.Migrations.RemoveUserStatuses do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :status
      remove :deleted_at
      remove :active_at
      remove :frozen_at
      remove :graduated_at
    end
  end
end
