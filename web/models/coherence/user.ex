defmodule CoursePlanner.User do
  @moduledoc false
  use CoursePlanner.Web, :model
  use Coherence.Schema
  alias CoursePlanner.Types.UserRole

  schema "users" do
    field :name, :string
    field :family_name, :string
    field :nickname, :string
    field :email, :string
    field :student_id, :string
    field :comments, :string
    field :role, UserRole
    field :deleted_at, Ecto.DateTime

    coherence_schema()
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params,
      [:name, :family_name, :nickname, :email, :student_id, :comments, :role,
       :deleted_at]
      ++ coherence_fields())
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :create) do
    model
    |> cast(params,
      [:name, :family_name, :nickname, :email, :student_id, :comments, :role,
       :reset_password_token, :reset_password_sent_at])
  end

  def changeset(model, params, :password) do
    model
    |> cast(params,
      ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end

  def changeset(model, params, :delete) do
    model
    |> cast(params,
      [:deleted_at])
  end
end
