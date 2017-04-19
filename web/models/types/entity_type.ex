defmodule CoursePlanner.Types.EntityType do
  @behaviour Ecto.Type
  def type, do: :string

  @valid_entity_types ['Planned', 'Active', 'Finished', 'Graduated', 'Frozen', 'Deleted']

  def valid_entity_types, do: @valid_entity_types

  def cast(value) do
    cond do
      Enum.member?(@valid_entity_types, value) -> value
      true -> :error
    end
  end

  def load(value), do: value

  def dump(value) do
    cond do
      Enum.member?(@valid_entity_types, value) -> value
      true -> :error
    end
  end
end
