defmodule CoursePlanner.Repo.Migrations.RemoveStatus do
  use Ecto.Migration

  def up do
    execute("""
      DROP TYPE IF EXISTS entity_status;
    """)
  end

  def down do
    execute("""
      CREATE TYPE entity_status AS ENUM (
        'Planned',
        'Active',
        'Finished',
        'Graduated',
        'Frozen',
        'Deleted'
      );
    """)
  end
end
