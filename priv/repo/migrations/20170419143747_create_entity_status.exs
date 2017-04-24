defmodule CoursePlanner.Repo.Migrations.CreateEntityStatus do
  use Ecto.Migration

  def change do
    execute("""
          CREATE TYPE entity_status AS ENUM (
            'Planned',
            'Active',
            'Finished',
            'Graduated',
            'Frozen',
            'Deleted'
          )
        """)
  end
end
