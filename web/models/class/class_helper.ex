defmodule CoursePlanner.ClassHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Class}
  alias Ecto.TimeDate

  def delete(class) do
    case class.status do
      "Planned" -> hard_delete_class(class)
      _         -> soft_delete_class(class)
    end
  end

  defp soft_delete_class(class) do
    changeset = change(class, %{deleted_at: TimeDate.utc()})
    Repo.update(changeset)
  end

  defp hard_delete_class(class) do
    Repo.delete!(class)
  end

  def all_none_deleted do
    query = from c in Class , where: is_nil(c.deleted_at)
    Repo.all(query)
  end

  def is_class_duration_correct?(class) do
    TimeDate.compare(class.starting_at, class.finishes.at) == :lt
      && TimeDate.to_erl(class.starting_at) != 0
  end

  def get_class_name(class_id) do
    Repo.get!(Class, class_id).name
  end
end
