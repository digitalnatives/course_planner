defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.Terms.Term
  import Ecto.Query, only: [from: 2]

  def new do
    Term.changeset(%Term{})
  end

  def create_term(params) do
    %Term{}
    |> Term.changeset(params)
    |> Repo.insert
  end

  def get(id) do
    query = from t in Term, where: is_nil(t.deleted_at)
    Repo.get(query, id)
  end
end
