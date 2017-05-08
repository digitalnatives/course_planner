defmodule CoursePlanner.Repo.Migrations.RenameUserStatus do
  use Ecto.Migration

  def change do
    rename table(:users), :activated_at, to: :active_at
    rename table(:users), :froze_at, to: :frozen_at
  end
end
