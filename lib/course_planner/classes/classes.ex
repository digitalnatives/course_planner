defmodule CoursePlanner.Classes do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  import Ecto.Changeset
  import Ecto.Query

  alias CoursePlanner.{Repo, Classes.Class, Notifications.Notifier, Notifications}
  alias CoursePlanner.Terms.Term
  alias Ecto.{Changeset, DateTime, Date}

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

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
    Notifications.new()
    |> Notifications.type(type)
    |> Notifications.resource_path(path)
    |> Notifications.to(user)
    |> @notifier.notify_later()
  end

  defp get_subscribed_students(class) do
    class = class
    |> Repo.preload([:offered_course, offered_course: :students])
    class.offered_course.students
  end

  def get_offered_course_classes(offered_course_id) do
    Repo.all(from c in Class, where: c.offered_course_id == ^offered_course_id)
  end

  def classes_with_attendances(offered_course_id, user_id) do
    query = from c in Class,
      left_join: a in assoc(c, :attendances), on: a.student_id == ^user_id,
      where: c.offered_course_id == ^offered_course_id,
      order_by: [c.date, c.starting_at],
      select: %{
        classroom: c.classroom,
        date: c.date,
        starting_at: c.starting_at,
        attendance_type: a.attendance_type
      }

    Repo.all(query)
  end

  def sort_by_starting_time(classes) do
    Enum.sort(classes, fn (class_a, class_b) ->
      class_a_datetime = DateTime.from_date_and_time(class_a.date, class_a.starting_at)
      class_b_datetime = DateTime.from_date_and_time(class_b.date, class_b.starting_at)
      DateTime.compare(class_a_datetime, class_b_datetime) == :lt
    end)
  end

  def split_past_and_next(classes) do
    now = DateTime.utc
    {reversed_past_classes, next_classes} =
      Enum.split_with(classes, fn class ->
        class_datetime = DateTime.from_date_and_time(class.date, class.starting_at)
        DateTime.compare(class_datetime, now) == :lt
      end)

    {Enum.reverse(reversed_past_classes), next_classes}
  end
end
