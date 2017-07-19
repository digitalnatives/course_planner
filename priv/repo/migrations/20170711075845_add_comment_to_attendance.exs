defmodule CoursePlanner.Repo.Migrations.AddCommentToAttendance do
  use Ecto.Migration

  def change do
    alter table(:attendances) do
      add :comment, :string
    end
  end
end
