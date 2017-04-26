defmodule CoursePlanner.Types.ParticipationType do
  @moduledoc """
    This module introduces a custom type for Ecto for checking
    user participation type in the user model.
  """
  @behaviour Ecto.Type
  def type, do: :participation_type

  @valid_values ["Oficial", "Guest"]

  def values, do: @valid_values

  def cast(value) do
    case Enum.member?(@valid_values, value) do
      :true  -> {:ok, value}
      :false -> :error
    end
  end

  def load(value), do: {:ok, value}

  def dump(value) do
    case Enum.member?(@valid_values, value) do
      :true  -> {:ok, value}
      :false -> :error
    end
  end
end
