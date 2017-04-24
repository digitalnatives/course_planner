defmodule CoursePlanner.Repo.Migrations.CreateCourse do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :weekday, :string

      timestamps()
    end

  end
end
