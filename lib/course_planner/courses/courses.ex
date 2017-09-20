defmodule CoursePlanner.Courses do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """

  alias CoursePlanner.{Repo, Courses.Course, Terms, Notifications.Notifier, Notifications}

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

  def get(id) do
    case Repo.get(Course, id) do
      nil -> {:error, :not_found}
      course -> {:ok, course}
    end
  end

  def delete(id) do
    case get(id) do
      {:ok, course} -> Repo.delete(course)
      error -> error
    end
  end

  def notify_user_course(course, current_user, notification_type, path \\ "/") do
    course
    |> Terms.get_subscribed_users()
    |> Enum.reject(fn %{id: id} -> id == current_user.id end)
    |> Enum.each(&(notify_user(&1, notification_type, path)))
  end

  def notify_user(user, type, path) do
    Notifications.new()
    |> Notifications.type(type)
    |> Notifications.resource_path(path)
    |> Notifications.to(user)
    |> @notifier.notify_later()
  end
end
