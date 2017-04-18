defmodule CoursePlanner.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :due, :date

      timestamps()
    end

  end
end
