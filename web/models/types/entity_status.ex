defmodule CoursePlanner.Types.EntityStatus do
  @moduledoc """
    This module introduces a custom type for Etco for checking status in the model
  """
  @behaviour Ecto.Type
  def type, do: :entity_status

  @valid_entity_types ["Planned", "Active", "Finished", "Graduated", "Frozen", "Deleted"]

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
end
