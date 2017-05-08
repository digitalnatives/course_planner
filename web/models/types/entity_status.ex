defmodule CoursePlanner.Types.EntityStatus do
  @moduledoc """
    This module introduces a custom type for Etco for checking status in the model
  """
  use CoursePlanner.Enum

  def type, do: :entity_status
  def valid_types, do: ["Planned", "Active", "Finished", "Graduated", "Frozen"]

end
