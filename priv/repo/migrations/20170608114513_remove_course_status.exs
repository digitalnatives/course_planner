defmodule CoursePlanner.Repo.Migrations.RemoveCourseStatus do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      remove :status
    end
  end
end
