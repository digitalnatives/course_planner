defmodule CoursePlanner.Types.UserRole do
  @moduledoc """
    This module introduces a custom type for Etco for checking user role in the user model
  """
  use CoursePlanner.Enum

  def type, do: :user_role
  def valid_types, do: ["Student", "Teacher", "Coordinator", "Volunteer"]
end
