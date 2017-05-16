defmodule CoursePlanner.Repo.Migrations.CreateOfferedCourse do
  use Ecto.Migration

  def change do
    create table(:offered_courses) do
      add :term_id, references(:terms, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false

      timestamps()
    end
    create index(:offered_courses, [:term_id])
    create index(:offered_courses, [:course_id])
  end
end
