defmodule CoursePlanner.Repo.Migrations.CreateOfferedCoursesTeachers do
  use Ecto.Migration

  def change do
    create table(:offered_courses_teachers, primary_key: false) do
      add :offered_course_id, references(:offered_courses, on_delete: :delete_all), null: false
      add :teacher_id, references(:users, on_delete: :delete_all), null: false
    end
    create index(:offered_courses_teachers, [:offered_course_id])
    create index(:offered_courses_teachers, [:teacher_id])
  end
end
