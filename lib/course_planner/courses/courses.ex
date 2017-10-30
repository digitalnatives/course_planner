defmodule CoursePlanner.Courses do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  import Ecto.Query

  alias CoursePlanner.{Repo, Courses.Course, Terms, Notifications.Notifier, Notifications}

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

  def all do
    query = from c in Course, order_by: [asc: c.name]
    Repo.all(query)
  end

  def delete(id) do
    course = Repo.get(Course, id)
    if is_nil(course) do
      {:error, :not_found}
    else
      Repo.delete(course)
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
