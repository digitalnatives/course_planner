defmodule CoursePlanner.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute("""
          CREATE TYPE user_role AS ENUM (
            'Student',
            'Teacher',
            'Coordinator',
            'Volunteer'
          )
        """)
    execute("""
          CREATE TYPE participation_type AS ENUM (
            'Official',
            'Guest'
          )
    """)
    create table(:users) do
      add :name, :string
      add :email, :string
      add :family_name, :text
      add :nickname, :string
      add :student_id, :string
      add :comments, :string
      add :role, :user_role
      add :participation_type, :participation_type
      add :phone_number, :string
      add :notified_at, :naive_datetime
      add :notification_period_days, :integer, null: false, default: 1

      # authenticatable
      add :password_hash, :string
      # recoverable
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      # lockable
      add :failed_attempts, :integer, default: 0
      add :locked_at, :utc_datetime
      # trackable
      add :sign_in_count, :integer, default: 0
      add :current_sign_in_at, :utc_datetime
      add :last_sign_in_at, :utc_datetime
      add :current_sign_in_ip, :string
      add :last_sign_in_ip, :string
      # unlockable_with_token
      add :unlock_token, :string

      timestamps()
    end
    create unique_index(:users, [:email])

  end
end
