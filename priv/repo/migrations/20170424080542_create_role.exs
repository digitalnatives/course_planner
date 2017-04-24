defmodule CoursePlanner.Repo.Migrations.CreateRole do
  use Ecto.Migration
  alias CoursePlanner.Types.UserRole

  def change do
    execute("""
          CREATE TYPE user_role AS ENUM (
            'Student',
            'Teacher',
            'Organizer'
          )
        """)
    alter table(:users) do
      add :role, :user_role
    end
  end



end
