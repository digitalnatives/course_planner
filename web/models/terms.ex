defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.{Repo, Notifier, Coordinators, Notifier.Notification}
  alias CoursePlanner.Terms.{Holiday, Term}
  alias Ecto.{Changeset, DateTime}
  import Ecto.Query, only: [from: 2]

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
    holidays =
      params
      |> Map.get("holidays", %{})
      |> Map.values()
      |> Enum.map(&Holiday.changeset(%Holiday{}, start_date, end_date, &1))

    Changeset.put_embed(changeset, :holidays, holidays)
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
    Notification.new()
    |> Notification.type(type)
    |> Notification.resource_path(path)
    |> Notification.to(user)
    |> Notifier.notify_user()
  end

  defp get_subscribed_users(term) do
    offered_courses = term
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
