defmodule CoursePlanner.Repo.Migrations.MigrateFieldsFromCourseToOfferedCourse do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      remove :session_duration
      remove :syllabus
      remove :number_of_sessions
    end

    alter table(:offered_courses) do
      add :syllabus, :text
      add :number_of_sessions, :integer
    end
  end
end
