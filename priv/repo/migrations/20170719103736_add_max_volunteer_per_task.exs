defmodule CoursePlanner.Repo.Migrations.AddMaxVolunteerPerTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :user_id
      add :max_volunteers, :integer
    end
  end
end
