defmodule CoursePlanner.Repo.Migrations.AddOfferedCourseUniqueIndex do
  use Ecto.Migration

  def change do
    create index(:offered_courses, [:term_id, :course_id], unique: true)
  end
end
