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
    target_params =
      [
       :value,
       :type
      ]

    struct
    |> cast(params, target_params)
    |> validate_required(target_params)
    |> validate_value_type()
    |> validate_editable()
  end

  defp validate_editable(%{valid?: true} = changeset) do
    editable = changeset |> Changeset.get_field(:editable)

    if editable do
      changeset
    else
      add_error(changeset, :value, "operation is forbidden")
    end
  end
  defp validate_editable(changeset), do: changeset

  defp validate_value_type(%{valid?: true} = changeset) do
    value = changeset |> Changeset.get_field(:value)
    type  = changeset |> Changeset.get_field(:type)

    validation_result = parse_value(value, type)

    case validation_result do
      {:ok, _} -> changeset
      {:error, message} -> add_error(changeset, :value, message)
    end
  end
  defp validate_value_type(changeset), do: changeset

  def parse_value(value, type) do
    case type do
      "string"  -> {:ok, value}
      "list"    -> parse_list(value)
      "integer" -> parse_integer(value)
      "boolean" -> parse_boolean(value)
      _         -> {:error, "unknown type"}
    end
  end

  def parse_list(value) do
    parse_list = String.split(value, [" ", ","] , trim: true)
    {:ok, parse_list}
  end

  def parse_integer(value) do
    case Integer.parse(value) do
      {parsed_value, ""} -> validate_number_range_inclusive(parsed_value, 0, 1_000_000)
      _                  -> {:error, "the given value should be a number"}
    end
  end

  defp validate_number_range_inclusive(number, min, max) do
    if number in (min..max) do
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
