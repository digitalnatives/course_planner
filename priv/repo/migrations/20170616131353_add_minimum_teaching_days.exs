defmodule CoursePlanner.Repo.Migrations.AddMinimumTeachingDays do
  use Ecto.Migration

  def change do
    alter table(:terms) do
      add :minimum_teaching_days, :integer, null: false, default: 1
    end
  end
end
