defmodule CoursePlanner.Types.ParticipationType do
  @moduledoc """
    This module introduces a custom type for Ecto for checking
    user participation type in the user model.
  """
  use CoursePlanner.Enum

  def type, do: :participation_type
  def valid_types, do: ["Official", "Guest"]
end
