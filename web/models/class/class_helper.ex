defmodule CoursePlanner.ClassHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Class, Notifier, Attendance, Notifier.Notification}
  alias Ecto.DateTime
  alias Ecto.Multi

  def delete(id) do
    class = Repo.get(Class, id)
    if is_nil(class) do
      {:error, :not_found}
    else
      Repo.delete(class)
    end
  end

  def is_class_duration_correct?(class) do
    DateTime.compare(class.starting_at, class.finishes.at) == :lt
      && DateTime.to_erl(class.starting_at) != 0
  end

  def create_class_attendance_records(class) do
    students = class.students

    if is_nil(students) do
      {:ok, nil}
    else
      attendances_data =
        students
        |> Enum.map(fn(student) ->
             [
               class_id: class.id,
               student_id: student.id,
               attendance_type: "Not filled",
               inserted_at: DateTime.utc(),
               updated_at: DateTime.utc()
             ]
           end)

      Multi.new
      |>  Multi.insert_all(:attendances, Attendance, attendances_data)
      |> Repo.transaction()
    end
  end

  def notify_class_students(class, current_user, notification_type, path \\ "/") do
    class
    |> get_subscribed_students()
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

  defp get_subscribed_students(class) do
    class = class
    |> Repo.preload([:offered_course, offered_course: :students])
    class.offered_course.students
  end
end
