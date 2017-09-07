defmodule CoursePlanner.Repo.Migrations.CreateSystemVariables do
  use Ecto.Migration

  def change do
    create table(:system_variables) do
      add :key, :string
      add :value, :text
      add :type, :string
      add :editable, :boolean
      add :visible, :boolean
      add :required, :boolean, null: false, default: true

      timestamps()
    end
  end
end
