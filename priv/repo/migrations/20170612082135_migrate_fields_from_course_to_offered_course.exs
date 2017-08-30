defmodule CoursePlanner.Repo.Migrations.MigrateFieldsFromCourseToOfferedCourse do
  use Ecto.Migration

  def change do
    alter table(:offered_courses) do
      add :syllabus, :text
      add :number_of_sessions, :integer
    end
  end
end
