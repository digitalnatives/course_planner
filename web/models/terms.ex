defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.{Repo, OfferedCourse, Notifier}
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
    |> Changeset.put_assoc(:offered_courses, course_changesets(params))
    |> Repo.insert
  end

  def course_changesets(%{"course_ids" => ids}) do
    Enum.map(ids, &OfferedCourse.add_to_term_changeset/1)
  end
  def course_changesets(_), do: []

  def get(id) do
    non_deleted_query()
    |> Repo.get(id)
    |> Repo.preload(:courses)
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
        |> Changeset.put_assoc(:offered_courses, course_changesets(params))
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

  def notify_term_users(term, notification_type) do
    term
    |> get_enrolled_students()
    |> Enum.each(&(Notifier.notify_user(&1, notification_type)))
  end

  defp get_enrolled_students(term) do
    term
    |> Repo.preload([:offered_courses])
    |> get_offered_courses()
    |> Enum.map(&(Repo.preload(&1, [:students])))
    |> Enum.map(&(&1.students))
    |> List.flatten()
  end
  defp get_offered_courses(term), do: term.offered_courses
end
