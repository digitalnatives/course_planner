defmodule CoursePlanner.Accounts.Volunteers do
  @moduledoc false
  import Ecto.Query
  alias CoursePlanner.{Repo, Accounts.User, Accounts.Users, Tasks.Task}

  @volunteers from u in User, where: u.role == "Volunteer",
    order_by: [u.name, u.family_name, u.nickname]

  def all do
    Repo.all(@volunteers)
  end

  def query do
    @volunteers
  end

  def get!(id) do
    Repo.get!(User, id)
  end

  def new(user, token) do
    user
    |> Map.put("role", "Volunteer")
    |> Users.new_user(token)
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

  def get_tasks(volunteer) do
    query = from t in Task,
      join: v in assoc(t, :volunteers),
      preload: [volunteers: v],
      where: v.id == ^volunteer.id

    Repo.all(query)
  end

  defp format_error({:ok, volunteer}, _), do: {:ok, volunteer}
  defp format_error({:error, changeset}, volunteer), do: {:error, volunteer, changeset}

end
