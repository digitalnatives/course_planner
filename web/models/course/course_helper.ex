defmodule CoursePlanner.CourseHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Course, Coordinators, Notifier, Notifier.Notification}

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
    |> get_subscribed_users()
    |> Enum.reject(fn %{id: id} -> id == current_user.id end)
    |> Enum.each(&(notify_user(&1, notification_type, path)))
  end

  def notify_user(user, type, path) do
    Notification.new()
    |> Notification.type(type)
    |> Notification.resource_path(path)
    |> Notification.to(user)
    |> Notifier.notify_user()
  end

  defp get_subscribed_users(course) do
    offered_courses = course
    |> Repo.preload([:offered_courses, offered_courses: :students, offered_courses: :teachers])
    |> Map.get(:offered_courses)

    students = offered_courses
    |> Enum.flat_map(&(Map.get(&1, :students)))
    |> Enum.uniq_by(fn %{id: id} -> id end)

    teachers = offered_courses
    |> Enum.flat_map(&(Map.get(&1, :teachers)))
    |> Enum.uniq_by(fn %{id: id} -> id end)

    students ++ teachers ++ Coordinators.all()
  end
end
