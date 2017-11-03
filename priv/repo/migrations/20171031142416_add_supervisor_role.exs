defmodule CoursePlanner.Repo.Migrations.AddSupervisorRole do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    execute("""
          ALTER TYPE user_role ADD VALUE 'Supervisor';
        """)
  end
end
