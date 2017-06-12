defmodule CoursePlanner.Repo.Migrations.RemoveClassStatus do
  use Ecto.Migration

  def change do
    alter table(:classes) do
     remove :status
     remove :deleted_at
    end
  end
end
