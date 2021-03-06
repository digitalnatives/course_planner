defmodule CoursePlanner.Classes do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  import Ecto.Changeset
  import Ecto.Query

  alias CoursePlanner.{Repo, Classes.Class, Notifications.Notifier, Notifications, Settings}
  alias CoursePlanner.Terms.Term
  alias Ecto.{Changeset, DateTime, Date}

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

  def all do
    query = from t in Term,
    join: oc in assoc(t, :offered_courses),
    join: co in assoc(oc, :course),
    join: c in assoc(oc, :classes),
    preload: [offered_courses: {oc, classes: c, course: co}],
    order_by: [desc: t.start_date, desc: co.name, desc: c.date,
               desc: c.starting_at, desc: c.finishes_at]

    Repo.all(query)
  end

  def new do
    Class.changeset(%Class{})
  end

  def get(id) do
    case Repo.get(Class, id) do
      nil -> {:error, :not_found}
      class -> {:ok, class}
    end
  end

  def edit(id) do
    case get(id) do
      {:ok, class} -> {:ok, class, Class.changeset(class)}
      error -> error
    end
  end

  def create(params) do
    %Class{}
    |> Class.changeset(params, :create)
    |> Repo.insert()
  end

  def update(id, params) do
    case get(id) do
      {:ok, class} ->
        class
        |> Class.changeset(params, :update)
        |> Repo.update()
        |> format_error(class)
      error -> error
    end
  end

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
    case get(id) do
      {:ok, class} -> Repo.delete(class)
      error -> error
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
    now = Settings.utc_to_system_timezone(Timex.now())
    {reversed_past_classes, next_classes} =
      Enum.split_with(classes, &(compare_class_date_time(&1, now)))

    {Enum.reverse(reversed_past_classes), next_classes}
  end

  defp format_error({:ok, class}, _), do: {:ok, class}
  defp format_error({:error, changeset}, class), do: {:error, class, changeset}

  defp compare_class_date_time(class, now) do
    class_datetime =
          class.date
          |> DateTime.from_date_and_time(class.starting_at)
          |> Settings.utc_to_system_timezone()

        Timex.compare(class_datetime, now) == -1
  end
end
