defmodule CoursePlanner.Volunteers do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query
  alias Ecto.{Changeset, DateTime}
  alias CoursePlanner.Users

  @volunteers from u in User, where: u.role == "Volunteer" and is_nil(u.deleted_at)

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
        |> add_timestamps()
        |> Repo.update
        |> format_error(volunteer)
    end
  end

  defp add_timestamps(%{changes: %{status: "Active"}} = changeset) do
    Changeset.put_change(changeset, :activated_at, DateTime.utc())
  end

  defp add_timestamps(%{changes: %{status: "Frozen"}} = changeset) do
    Changeset.put_change(changeset, :froze_at, DateTime.utc())
  end

  defp add_timestamps(changeset), do: changeset

  defp format_error({:ok, volunteer}, _), do: {:ok, volunteer}
  defp format_error({:error, changeset}, volunteer), do: {:error, volunteer, changeset}

end
