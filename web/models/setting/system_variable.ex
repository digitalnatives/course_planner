defmodule CoursePlanner.SystemVariable do
  @moduledoc """
  This module holds the model for one system variable
  """
  use CoursePlanner.Web, :model

  alias Ecto.Changeset

  schema "system_variables" do
    field :key,      :string
    field :value,    :string
    field :type,     :string
    field :visible,  :boolean
    field :editable, :boolean

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    target_params =
      [
       :key,
       :value,
       :type,
       :visible,
       :editable
      ]

    struct
    |> cast(params, target_params)
    |> validate_required(target_params)
    |> validate_value_type()
  end

  def changeset(struct, params, :update) do
    struct
    |> changeset(params)
    |> validate_editable()
  end

  defp validate_editable(%{changes: changes, valid?: true} = changeset) do
    editable = changeset |> Changeset.get_field(:editable) |> Date.cast!

    if editable do
      changeset
    else
      add_error(changeset, :value, "this field is not ediable by users")
    end
  end
  defp validate_editable(changeset), do: changeset

  defp validate_value_type(%{changes: changes, valid?: true} = changeset) do
    key   = changeset |> Changeset.get_field(:key)
    value = changeset |> Changeset.get_field(:value)
    type  = changeset |> Changeset.get_field(:type)

    validation_result =
      case type do
        "string"  -> {:ok, value}
        "integer" -> parse_integer(value)
        "boolean" -> parse_boolean(value)
        _         -> {:error, "unknown type"}
      end

    case validation_result do
      {:ok, _} -> changeset
      {:error, message} -> add_error(changeset, :value, message)
    end
  end
  defp validate_value_type(changeset), do: changeset

  def parse_integer(value) do
    case Integer.parse(value) do
      {parsed_value, ""} -> validate_number_rage_inclusive(parsed_value, 0, 1_000_000_000)
      _                  -> {:error, "the given value should be a number"}
    end
  end

  defp validate_number_rage_inclusive(number, min, max) do
    if number >=min && number <= max do
      {:ok, number}
    else
      {:error, "the given value should be between #{min} and #{max}"}
    end
  end

  defp parse_boolean(value) do
    case String.downcase(value) do
      "true"  -> {:ok, true}
      "false" -> {:ok, false}
      _       -> {:error, "the given value should be true or false"}
    end
  end
end
