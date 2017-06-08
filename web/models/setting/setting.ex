defmodule CoursePlanner.Setting do
  @moduledoc """
  This module holds the model for the setting table
  """
  use CoursePlanner.Web, :model

  schema "settings" do
    field :notification_frequency, :integer
    field :program_name, :string
    field :program_description, :string
    field :program_phone_number, :string
    field :program_email_address, :string
    field :program_address, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    target_params =
      [
       :notification_frequency,
       :program_name,
       :program_description,
       :program_phone_number,
       :program_email_address,
       :program_address
      ]

    struct
    |> cast(params, target_params)
    |> validate_required(target_params)
    |> validate_inclusion(:notification_frequency, 1..31)
  end
end
