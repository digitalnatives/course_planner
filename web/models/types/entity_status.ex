defmodule CoursePlanner.Types.EntityStatus do
  @moduledoc """
    This module introduces a custom type for Etco for checking status in the model
  """
  @behaviour Ecto.Type
  @behaviour EnumTimestamp
  def type, do: :entity_status

  @valid_entity_types ["Planned", "Active", "Finished", "Graduated", "Frozen"]

  def valid_entity_types, do: @valid_entity_types

  def values, do: @valid_entity_types

  def cast(value) when value in @valid_entity_types, do: {:ok, value}
  def cast(_value), do: :error

  def load(value), do: {:ok, value}

  def dump(value) when value in @valid_entity_types, do: {:ok, value}
  def dump(_value), do: :error

  def valid_types, do: @valid_entity_types
  def types_timestamp do
    Enum.into(valid_types(), %{}, &({&1, :"#{String.downcase(&1)}_at"}))
  end

end
