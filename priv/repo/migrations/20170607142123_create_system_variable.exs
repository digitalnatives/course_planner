defmodule CoursePlanner.Repo.Migrations.CreateSystemVariable do
  use Ecto.Migration

  def change do
    create table(:system_variables) do
      add :key, :string
      add :value, :string
      add :type, :string
      add :editable, :boolean
      add :visible, :boolean

      timestamps()
    end

  end
end
