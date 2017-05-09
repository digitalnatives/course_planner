defmodule CoursePlanner.Repo.Migrations.Classroom do
  use Ecto.Migration

  def change do
    alter table(:classes) do
      add :classroom, :string
    end
  end
end
