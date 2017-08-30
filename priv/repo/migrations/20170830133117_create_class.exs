defmodule CoursePlanner.Repo.Migrations.CreateClass do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :date, :date
      add :starting_at, :time
      add :finishes_at, :time
      add :classroom, :string
      add :offered_course_id, references(:offered_courses, on_delete: :delete_all), null: false

      timestamps()
    end
    create index(:classes, [:offered_course_id])
  end
end
