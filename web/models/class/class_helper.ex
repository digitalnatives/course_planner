defmodule CoursePlanner.ClassHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Class, Notifier}
  alias Ecto.DateTime

  def delete(id) do
    class = Repo.get(Class, id)
    if is_nil(class) do
      {:error, :not_found}
    else
      case class.status do
        "Planned" -> hard_delete_class(class)
        _         -> soft_delete_class(class)
      end
    end
  end

  defp soft_delete_class(class) do
    changeset = change(class, %{deleted_at: DateTime.utc()})
    Repo.update(changeset)
  end

  defp hard_delete_class(class) do
    Repo.delete(class)
  end

  def all_none_deleted do
    Repo.all(non_deleted_query())
  end

  def is_class_duration_correct?(class) do
    DateTime.compare(class.starting_at, class.finishes.at) == :lt
      && DateTime.to_erl(class.starting_at) != 0
  end

  defp non_deleted_query do
    from c in Class , where: is_nil(c.deleted_at)
  end

  def notify_class_students(class, notification_type) do
    class
    |> get_subscribed_students()
    |> Enum.each(&(Notifier.notify_user(&1, notification_type)))
  end

  defp get_subscribed_students(class) do
    class = class
    |> Repo.preload([:offered_course, offered_course: :students])
    class.offered_course.students
  end
end
