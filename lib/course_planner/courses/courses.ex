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

  def new do
    Course.changeset(%Course{})
  end

  def get(id) do
    case Repo.get(Course, id) do
      nil -> {:error, :not_found}
      course -> {:ok, course}
    end
  end

  def insert(params) do
    %Course{}
    |> Course.changeset(params, :create)
    |> Repo.insert()
  end

  def edit(id) do
    case get(id) do
      {:ok, course} -> {:ok, course, Course.changeset(course)}
      error -> error
    end
  end

  def update(id, params) do
    case get(id) do
      {:ok, course} ->
        course
        |> Course.changeset(params)
        |> Repo.update()
        |> format_update_error(course)
      error -> error
    end
  end

  defp format_update_error({:ok, _} = result, _), do: result
  defp format_update_error({:error, changeset}, course), do: {:error, course, changeset}

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
