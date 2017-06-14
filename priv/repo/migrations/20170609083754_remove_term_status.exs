defmodule CoursePlanner.Repo.Migrations.RemoveUserStatus do
  use Ecto.Migration

  def change do
    alter table(:terms) do
     remove :status
     remove :planned_at
     remove :active_at
     remove :frozen_at
     remove :finished_at
     remove :deleted_at
    end
  end
end
