defmodule CoursePlanner.Accounts.User do
  @moduledoc false
  use CoursePlannerWeb, :model
  use Coherence.Schema
  alias CoursePlanner.Types.{UserRole, ParticipationType}
  alias CoursePlanner.Notifications.Notification

  @target_params [
      :name, :family_name, :nickname,
      :email, :student_id, :comments,
      :role, :participation_type,
      :phone_number, :notified_at,
      :notification_period_days
    ]

  schema "users" do
    field :name, :string
    field :family_name, :string
    field :nickname, :string
    field :email, :string
    field :phone_number, :string
    field :student_id, :string
    field :comments, :string
    field :role, UserRole
    field :participation_type, ParticipationType
    field :notified_at, :naive_datetime
    field :notification_period_days, :integer
    has_many :notifications, Notification, on_delete: :delete_all

    coherence_schema()
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @target_params ++ coherence_fields())
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:comments, max: 255)
    |> validate_coherence(params)
    |> validate_number(:notification_period_days,
      greater_than_or_equal_to: 1, less_than_or_equal_to: 7)
  end

  def changeset(model, params, :password) do
    model
    |> cast(params,
      ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end

  def changeset(model, params, :seed) do
    changeset(model, params)
  end

  def changeset(model, params, :update) do
    changeset(model, params)
  end
end
