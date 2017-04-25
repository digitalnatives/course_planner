defmodule CoursePlanner.Repo.Migrations.RenameTermsStatusTimestamps do
  use Ecto.Migration

  def change do
    rename table(:terms), :activated_at, to: :active_at
    rename table(:terms), :froze_at, to: :frozen_at
  end
end
