defmodule CoursePlanner.Repo.Migrations.CreateSetting do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :notification_frequency, :integer
      add :program_name, :string
      add :program_description, :string
      add :program_phone_number, :string
      add :program_email_address, :string
      add :program_address, :string

      timestamps()
    end

  end
end
