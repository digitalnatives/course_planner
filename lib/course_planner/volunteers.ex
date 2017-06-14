defmodule CoursePlanner.Volunteers do
  @moduledoc false
  import Ecto.Query
  alias Ecto.Changeset
  alias CoursePlanner.{Repo, User, Users}

  @volunteers from u in User, where: u.role == "Volunteer"

  def all do
    Repo.all(@volunteers)
  end

  def get!(id) do
    Repo.get!(User, id)
  end

  def new(user, token) do
    user
    |> Users.new_user(token)
    |> Changeset.put_change(:role, "Volunteer")
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      volunteer ->
        volunteer
        |> User.changeset(params, :update)
        |> Repo.update
        |> format_error(volunteer)
    end
  end

  defp format_error({:ok, volunteer}, _), do: {:ok, volunteer}
  defp format_error({:error, changeset}, volunteer), do: {:error, volunteer, changeset}

end
