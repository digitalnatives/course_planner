defmodule CoursePlanner.Students do
  @moduledoc """
    Handle Students specific logics
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query
  alias Ecto.{Changeset, DateTime}
  alias CoursePlanner.Users

  @students from u in User, where: u.role == "Student" and is_nil(u.deleted_at)

  def all do
    Repo.all(@students)
  end

  def new(user, token) do
    user
    |> Users.new_user(token)
    |> Changeset.put_change(:role, "Student")
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      student ->
        student
        |> User.changeset(params)
        |> add_timestamps()
        |> Repo.update
        |> format_error(student)
    end
  end

  defp add_timestamps(%{changes: %{status: "Graduated"}} = changeset) do
    Changeset.put_change(changeset, :graduated_at, DateTime.utc())
  end

  defp add_timestamps(%{changes: %{status: "Active"}} = changeset) do
    Changeset.put_change(changeset, :activated_at, DateTime.utc())
  end

  defp add_timestamps(%{changes: %{status: "Frozen"}} = changeset) do
    Changeset.put_change(changeset, :froze_at, DateTime.utc())
  end

  defp add_timestamps(changeset), do: changeset

  defp format_error({:ok, student}, _), do: {:ok, student}
  defp format_error({:error, changeset}, student), do: {:error, student, changeset}

end
