defmodule CoursePlanner.CourseHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model
  import Ecto.DateTime, only: [utc: 0]

  alias CoursePlanner.{Repo, Course, Notifier}

  def delete(course) do
    case course.status do
      "Planned" -> hard_delete_course(course)
      _         -> soft_delete_course(course)
    end
  end

  defp soft_delete_course(course) do
    changeset = change(course, %{deleted_at: utc()})
    Repo.update(changeset)
  end

  defp hard_delete_course(course) do
    Repo.delete!(course)
  end

  def all_none_deleted do
    query = from c in Course , where: is_nil(c.deleted_at)
    Repo.all(query)
  end

  def notify_user_course(course, current_user, notification_type) do
    course
    |> get_subscribed_students()
    |> Enum.reject(fn %{id: id} -> id == current_user.id end)
    |> Enum.each(&(Notifier.notify_user(&1, notification_type)))
  end

  defp get_subscribed_students(course) do
    course
    |> Repo.preload([:offered_courses, offered_courses: :students])
    |> Map.get(:offered_courses)
    |> Enum.map(&(Map.get(&1, :students)))
    |> List.flatten()
    |> Enum.uniq_by(fn %{id: id} -> id end)
  end
end
