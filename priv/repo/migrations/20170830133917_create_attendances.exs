defmodule CoursePlanner.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :attendance_type, :string
      add :comment, :string
      add :student_id, references(:users, on_delete: :delete_all)
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps()
    end
    create index(:attendances, [:student_id])
    create index(:attendances, [:class_id])
  end
end
