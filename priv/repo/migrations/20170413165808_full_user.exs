defmodule CoursePlanner.Repo.Migrations.FullUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :family_name, :text
      add :nickname, :string
      add :student_id, :string
      add :comments, :string
    end
    rename table(:users), :name, to: :first_name

  end
end
