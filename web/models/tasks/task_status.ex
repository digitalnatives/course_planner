defmodule CoursePlanner.Tasks.TaskStatus do
  use CoursePlanner.Enum

  def type, do: :task_status
  def valid_types, do: ["Pending", "Accomplished"]

end
