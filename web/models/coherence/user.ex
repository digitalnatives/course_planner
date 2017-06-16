defmodule CoursePlanner.User do
  @moduledoc false
  use CoursePlanner.Web, :model
  use Coherence.Schema
  alias CoursePlanner.Types.{UserRole, ParticipationType}
  alias CoursePlanner.Tasks.Task
  @target_params [
      :name, :family_name, :nickname,
      :email, :student_id, :comments,
      :role, :participation_type,
      :phone_number
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
    has_many :tasks, Task, on_delete: :nilify_all

    coherence_schema()
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @target_params ++ coherence_fields())
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def changeset(model, params, :password) do
    model
    |> cast(params,
      ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end

  def changeset(model, params, :seed) do
    model
    |> cast(params, @target_params ++ coherence_fields())
    |> validate_coherence(params)
  end

  def changeset(model, params, :update) do
    model
    |> cast(params, @target_params ++ coherence_fields())
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
