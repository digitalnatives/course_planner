defmodule CoursePlanner.StudentStatus do
  @moduledoc """
    This module represents the possible student statuses
  """
  use CoursePlanner.Enum

  def type, do: :student_status
  def valid_types, do: ["Active", "Graduated", "Frozen"]
end
