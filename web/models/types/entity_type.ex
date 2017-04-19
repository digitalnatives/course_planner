defmodule CoursePlanner.Types.EntityType do
  @moduledoc """
    This module introduces a custom type for Etco for checking status in the model
  """
  @behaviour Ecto.Type
  def type, do: :string

  @valid_entity_types ['Planned', 'Active', 'Finished', 'Graduated', 'Frozen', 'Deleted']

  def valid_entity_types, do: @valid_entity_types

  def cast(value) do
    case Enum.member?(@valid_entity_types, value) do
      :true  -> value
      :false -> :error
    end
  end

  def load(value), do: value

  def dump(value) do
    case Enum.member?(@valid_entity_types, value) do
      :true  -> value
      :false -> :error
    end
  end
end
