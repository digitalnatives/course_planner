defmodule CoursePlanner.Terms do
  @moduledoc """
    Handle all interactions with Terms, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.Terms.Term

  def create_term(params) do
    %Term{}
    |> Term.changeset(params)
    |> CoursePlanner.Repo.insert
  end
end
