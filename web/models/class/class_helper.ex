defmodule CoursePlanner.ClassHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Class, Notifier, Attendance, Notifier.Notification}
  alias CoursePlanner.Terms.Term
  alias Ecto.{Changeset, DateTime, Date}
  alias Ecto.Multi

  def validate_for_holiday(%{valid?: true} = changeset) do
    class_date = changeset |> Changeset.get_field(:date) |> Date.cast!
    offered_course_id = changeset |> Changeset.get_field(:offered_course_id)

    term = Repo.one(from t in Term,
      join: oc in assoc(t, :offered_courses),
      where: oc.id == ^offered_course_id)

    class_on_holiday? =
      Enum.find(term.holidays, fn(holiday) ->
        holiday.date
        |> Date.cast!
        |> Date.compare(class_date)
        |> Kernel.==(:eq)
      end)

    if class_on_holiday? do
      add_error(changeset, :date, "Cannot create a class on holiday")
    else
      changeset
    end
  end
  def validate_for_holiday(changeset), do: changeset

  def delete(id) do
    class = Repo.get(Class, id)
    if is_nil(class) do
      {:error, :not_found}
    else
      Repo.delete(class)
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
