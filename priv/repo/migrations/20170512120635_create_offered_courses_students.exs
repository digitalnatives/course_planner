defmodule CoursePlanner.Repo.Migrations.CreateOfferedCoursesStudents do
  use Ecto.Migration

  def change do
    create table(:offered_courses_students, primary_key: false) do
      add :offered_course_id, references(:offered_courses, on_delete: :delete_all), null: false
      add :student_id, references(:users, on_delete: :delete_all), null: false
    end
    create index(:offered_courses_students, [:offered_course_id])
    create index(:offered_courses_students, [:student_id])
  end
end
