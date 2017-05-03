defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.Terms.Term
  alias Ecto.{Changeset, DateTime}
  import Ecto.Query, only: [from: 2]

  def all do
    Repo.all(non_deleted_query())
  end

  def new do
    Term.changeset(%Term{})
  end

  def create_term(params) do
    %Term{}
    |> Term.changeset(params)
    |> Repo.insert
  end

  def get(id) do
    Repo.get(non_deleted_query(), id)
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
        with changeset <- Term.changeset(term, params),
             {:error, changeset} <- Repo.update(changeset),
             do: {:error, term, changeset}
    end
  end

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
end
