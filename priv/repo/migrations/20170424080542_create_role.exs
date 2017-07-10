defmodule CoursePlanner.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    execute("""
          CREATE TYPE user_role AS ENUM (
            'Student',
            'Teacher',
            'Coordinator',
            'Volunteer'
          )
        """)
    alter table(:users) do
      add :role, :user_role
    end
  end
end
