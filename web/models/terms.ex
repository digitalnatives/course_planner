defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.Terms.Term

  def new do
    Term.changeset(%Term{})
  end

  def create_term(params) do
    %Term{}
    |> Term.changeset(params)
    |> Repo.insert
  end
end
