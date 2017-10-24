defmodule CoursePlanner.Repo.Migrations.ChangeUserCommentToText do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :comments, :text
    end
  end
end
