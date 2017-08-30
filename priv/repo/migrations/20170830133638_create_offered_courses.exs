defmodule CoursePlanner.Repo.Migrations.CreateOfferedCourses do
  use Ecto.Migration

  def change do
    create table(:offered_courses) do
      add :syllabus, :text
      add :number_of_sessions, :integer
      add :term_id, references(:terms, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false

      timestamps()
    end
    create index(:offered_courses, [:term_id])
    create index(:offered_courses, [:course_id])
    create index(:offered_courses, [:term_id, :course_id], unique: true)

    alter table(:classes) do
      add :offered_course_id, references(:offered_courses, on_delete: :delete_all), null: false
    end
    create index(:classes, [:offered_course_id])
  end
end
