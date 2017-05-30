defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.{Repo, Notifier, Coordinators}
  alias CoursePlanner.Terms.Term
  alias Ecto.{Changeset, DateTime}
  import Ecto.Query, only: [from: 2]

  def all do
    Repo.all(non_deleted_query())
  end

  def new do
    Term.changeset(%Term{holidays: [], courses: []})
  end

  def create(params) do
    %Term{}
    |> Term.changeset(params)
    |> Repo.insert
  end

  def get(id) do
    non_deleted_query()
    |> Repo.get(id)
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
        params = Map.put_new(params, "holidays", [])
        term
        |> Term.changeset(params)
        |> Repo.update
        |> format_update_error(term)
    end
  end

  defp format_update_error({:ok, _} = result, _), do: result
  defp format_update_error({:error, changeset}, term), do: {:error, term, changeset}

  def delete(id) do
    case get(id) do
      nil -> {:error, :not_found}
      term ->
        term
        |> Term.changeset()
        |> Changeset.put_change(:deleted_at, DateTime.utc())
        |> Repo.update()
    end
  end

  defp non_deleted_query do
    from t in Term, where: is_nil(t.deleted_at)
  end

  def notify_term_users(term, current_user, notification_type) do
    term
    |> get_subscribed_users()
    |> Enum.reject(fn %{id: id} -> id == current_user.id end)
    |> Enum.each(&(Notifier.notify_user(&1, notification_type)))
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
