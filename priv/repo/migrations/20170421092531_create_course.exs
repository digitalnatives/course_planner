defmodule CoursePlanner.Repo.Migrations.CreateCourse do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :description, :string
      add :number_of_sessions, :integer
      add :session_duration, :time
      add :syllabus, :string
      add :status, :entity_status
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
