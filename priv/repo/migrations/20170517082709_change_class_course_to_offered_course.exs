defmodule CoursePlanner.Repo.Migrations.ChangeClassCourseToOfferedCourse do
  use Ecto.Migration

  def change do
    alter table(:classes) do
      remove :course_id
      add :offered_course_id, references(:offered_courses, on_delete: :delete_all), null: false
    end
  end
end
