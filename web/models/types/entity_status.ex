defmodule CoursePlanner.Types.EntityStatus do
  @moduledoc """
    This module introduces a custom type for Etco for checking status in the model
  """
  @behaviour Ecto.Type
  def type, do: :entity_status

  @valid_entity_types ["Planned", "Active", "Finished", "Graduated", "Frozen"]

  def values, do: @valid_entity_types

  def cast(value) do
    case Enum.member?(@valid_entity_types, value) do
      :true  -> {:ok, value}
      :false -> :error
    end
  end

  def load(value), do: {:ok, value}

  def dump(value) do
    case Enum.member?(@valid_entity_types, value) do
      :true  -> {:ok, value}
      :false -> :error
    end
  end

  def timestamp_field do
    Enum.into(
      values, %{}, fn status ->
        {status, :"#{String.downcase(status)}_at"}
      end)
  end

end
