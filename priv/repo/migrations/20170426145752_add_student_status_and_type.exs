defmodule CoursePlanner.Repo.Migrations.AddStudentStatusAndType do
  use Ecto.Migration

  def change do
    execute("""
          CREATE TYPE participation_type AS ENUM (
            'Official',
            'Guest'
          )
    """)
    alter table(:users) do
      add :status, :entity_status
      add :activated_at, :naive_datetime
      add :froze_at, :naive_datetime
      add :graduated_at, :naive_datetime
      add :participation_type, :participation_type
    end

  end
end
