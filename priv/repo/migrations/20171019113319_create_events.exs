defmodule CoursePlanner.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :description, :text
      add :date, :date
      add :starting_time, :time
      add :finishing_time, :time
      add :location, :string

      timestamps()
    end

  end
end
