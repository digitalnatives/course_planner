defmodule CoursePlanner.Types.UserRole do
  @moduledoc """
    This module introduces a custom type for Etco for checking user role in the user model
  """
  @behaviour Ecto.Type
  def type, do: :user_role

  @valid_values ["Student", "Teacher", "Organizer"]

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
