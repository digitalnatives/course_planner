defmodule CoursePlanner.Accounts.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias CoursePlanner.Types.{UserRole, ParticipationType}
  alias CoursePlanner.Notifications.Notification
  alias Ecto.Changeset
  alias Comeonin.Bcrypt

  @target_params [
      :name, :family_name, :nickname,
      :email, :student_id, :comments,
      :role, :participation_type,
      :phone_number, :notified_at,
      :notification_period_days,
      :current_password, :password, :password_confirmation, :password_hash,
      :reset_password_token, :reset_password_sent_at,
      :failed_attempts, :locked_at,
      :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip,
      :unlock_token
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

    field :password_hash, :string
    field :current_password, :string, virtual: true
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    field :reset_password_token, :string
    field :reset_password_sent_at, Ecto.DateTime

    field :failed_attempts, :integer, default: 0
    field :locked_at, Ecto.DateTime

    field :sign_in_count, :integer, default: 0
    field :current_sign_in_at, Ecto.DateTime
    field :last_sign_in_at, Ecto.DateTime
    field :current_sign_in_ip, :string
    field :last_sign_in_ip, :string

    field :unlock_token, :string

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @target_params)
    |> update_change(:email, &String.downcase/1)
    |> validate_required([:email, :role])
    |> validate_email_format(:email)
    |> unique_constraint(:email)
    |> validate_length(:comments, max: 255)
    |> validate_number(:notification_period_days,
      greater_than_or_equal_to: 1, less_than_or_equal_to: 7)
  end

  def changeset(model, params, :password_reset) do
    model
    |> cast(params,
      ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_required(:password)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> updates_hashed_password()

  end

  def changeset(model, params, :seed) do
    model
    |> changeset(params)
    |> validate_current_password()
    |> validate_password_if_changed()
  end

  def changeset(model, params, :create) do
    model
    |> changeset(params)
    |> validate_password_if_changed()
  end

  def changeset(model, params, :update) do
    model
    |> changeset(params)
    |> validate_current_password()
    |> validate_password_if_changed()
  end

  defp validate_email_format(changeset, field) do
    if Changeset.get_field(changeset, field) do
      do_validate_email_format(changeset, field)
    else
      changeset
    end
  end

  defp do_validate_email_format(changeset, field) do
    changeset
    |> Changeset.get_field(field)
    |> EmailChecker.valid?()
    |> case do
         true -> changeset
         false -> Changeset.add_error(changeset, field, "has invalid format", [validation: :format])
       end
  end

  def validate_current_password(%{changes: changes, valid?: true} = changeset) do
    password_hash = Map.get(changeset.data, :password_hash)
    current_password = Map.get(changes, :current_password)
    param_has_password = Map.has_key?(changes, :password)

    if param_has_password do
      do_validate_current_password(changeset, current_password, password_hash)
    else
      changeset
    end
  end
  def validate_current_password(changeset), do: changeset

  defp do_validate_current_password(changeset, current_password, password_hash) do
    if is_nil(current_password) do
      add_error(changeset, :current_password, "cant be blank.")
    else
      if Bcrypt.checkpw(current_password, password_hash) do
        changeset
      else
        add_error(changeset, :current_password, "current password is invalid.")
      end
    end
  end

  def validate_password_if_changed(%{changes: changes, valid?: true} = changeset) do
    password = Map.get(changes, :password)

    if password do
      changeset
      |> validate_length(:password, min: 6)
      |> validate_confirmation(:password)
      |> updates_hashed_password()
    else
      changeset
    end
  end
  def validate_password_if_changed(changeset), do: changeset

  defp updates_hashed_password(%{changes: changes, valid?: true} = changeset) do
    password = Map.get(changes, :password)

    changeset
    |> put_change(:password_hash, encrypt_password(password))
  end
  defp updates_hashed_password(changeset), do: changeset

  def encrypt_password(password) do
    Bcrypt.hashpwsalt(password)
  end
end
