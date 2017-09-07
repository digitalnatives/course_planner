defmodule CoursePlanner.Repo.Migrations.CreateTask do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :start_time, :naive_datetime
      add :finish_time, :naive_datetime
      add :description, :text
      add :max_volunteers, :integer, null: false, default: 1

      timestamps()
    end
  end
end
