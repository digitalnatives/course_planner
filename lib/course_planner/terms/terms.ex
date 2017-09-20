defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  import Ecto.Query

  alias CoursePlanner.{Repo, Courses.OfferedCourses, Notifications.Notifier,
                       Accounts.Coordinators, Notifications}
  alias CoursePlanner.Terms.{Holiday, Term}
  alias Ecto.Changeset

  @notifier Application.get_env(:course_planner, :notifier, Notifier)

  def all do
    Repo.all(Term)
  end

  def new do
    Term.changeset(%Term{holidays: [], courses: []})
  end

  def create(params) do
    %Term{}
    |> term_changeset_with_holidays(params)
    |> Repo.insert
  end

  def get(id) do
    Term
    |> Repo.get(id)
    |> Repo.preload([:courses])
  end

  def edit(id) do
    case get(id) do
      nil -> {:error, :not_found}
      term -> {:ok, term, Term.changeset(term)}
    end
  end

  def update(id, params) do
    case get(id) do
      nil -> {:error, :not_found}
      term ->
        term
        |> term_changeset_with_holidays(params)
        |> Repo.update
        |> format_update_error(term)
    end
  end

  defp format_update_error({:ok, _} = result, _), do: result
  defp format_update_error({:error, changeset}, term), do: {:error, term, changeset}

  defp term_changeset_with_holidays(term, params) do
    changeset = Term.changeset(term, params)
    start_date = Changeset.get_field(changeset, :start_date)
    end_date = Changeset.get_field(changeset, :end_date)
    holidays = get_holiday_changesets(params, start_date, end_date)

    changeset
    |> Changeset.put_embed(:holidays, holidays)
    |> Term.validate_minimum_teaching_days(holidays)
  end

  defp get_holiday_changesets(params, start_date, end_date) do
    params
    |> Map.get("holidays", %{})
    |> Map.values()
    |> Enum.map(&Holiday.changeset(%Holiday{}, start_date, end_date, &1))
  end

  def delete(id) do
    case get(id) do
      nil -> {:error, :not_found}
      term -> Repo.delete(term)
    end
  end

  def notify_term_users(term, current_user, notification_type, path \\ "/") do
    term
    |> get_subscribed_users()
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

  def get_subscribed_users(term) do
    offered_courses = term
    |> Repo.preload([:offered_courses, offered_courses: :students, offered_courses: :teachers])
    |> Map.get(:offered_courses)

    students_and_teachers = OfferedCourses.get_subscribed_users(offered_courses)
    students_and_teachers ++ Coordinators.all()
  end

  def find_all_by_user(%{role: "Coordinator"}) do
    Repo.all(from t in Term,
      join: oc in assoc(t, :offered_courses),
      join: co in assoc(oc, :course),
      preload: [offered_courses: {oc, course: co}],
      order_by: [asc: t.start_date, asc: co.name])
  end
  def find_all_by_user(%{role: "Teacher", id: user_id}) do
    Repo.all(from t in Term,
        join: oc in assoc(t, :offered_courses),
        join: co in assoc(oc, :course),
        join: te in assoc(oc, :teachers),
        preload: [offered_courses: {oc, course: co, teachers: te}],
        where: te.id == ^user_id,
        order_by: [asc: t.start_date, asc: co.name]
    )
  end
  def find_all_by_user(%{role: "Student", id: user_id}) do
    Repo.all(from t in Term,
      join: oc in assoc(t, :offered_courses),
      join: co in assoc(oc, :course),
      join: s in assoc(oc, :students),
      preload: [offered_courses: {oc, course: co, students: s}],
      where: s.id == ^user_id,
      order_by: [asc: t.start_date, asc: co.name]
    )
  end
end
