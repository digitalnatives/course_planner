defmodule CoursePlanner.Users do
  @moduledoc """
    Handle all interactions with Users, create, list, fetch, edit, and delete
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  alias Ecto.{Changeset, DateTime}

  def new_user(user, token) do
    %User{}
    |> User.changeset(user)
    |> Changeset.put_change(:reset_password_token, token)
    |> Changeset.put_change(:reset_password_sent_at, DateTime.utc())
    |> Changeset.put_change(:password, "fakepassword")
  end

  def get(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def delete(id) do
    case get(id) do
      {:ok, user} ->
        user
        |> User.changeset()
        |> Changeset.put_change(:deleted_at, DateTime.utc())
        |> Repo.update()
      error -> error
    end
  end
end
