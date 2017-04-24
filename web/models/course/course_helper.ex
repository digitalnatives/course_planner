defmodule CoursePlanner.CourseHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model
  import Ecto.DateTime, only: [utc: 0]

  alias CoursePlanner.Repo
  alias CoursePlanner.Course

  def delete_handler(course) do
    case course.status do
      "Planned" -> hard_delete_course(course)
      _         -> soft_delete_course(course)
    end
  end

  defp soft_delete_course(course) do
    changeset = change(course, %{status: "Deleted", deleted_at: utc()})
    Repo.update(changeset)
  end

  defp hard_delete_course(course) do
    Repo.delete!(course)
  end

  def all_excluding_status(value) do
    query = from c in Course, where: c.status != ^value
    Repo.all(query)
  end
end
