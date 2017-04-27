defmodule CoursePlanner.Repo.Migrations.TeacherPhoneNumber do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone_number, :string
    end
  end
end
