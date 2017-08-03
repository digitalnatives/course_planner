defmodule CoursePlanner.Repo.Migrations.ChangeSystemVariableValueToTextAddsRequired do
  use Ecto.Migration

  def change do
    alter table(:system_variables) do
      modify :value, :text
      add :required, :boolean, null: false, default: true
    end
  end
end
