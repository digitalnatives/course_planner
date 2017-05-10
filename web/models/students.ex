defmodule CoursePlanner.Students do
  @moduledoc """
    Handle Students specific logics
  """
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query
  alias CoursePlanner.Statuses
  alias CoursePlanner.StudentStatus
  alias Ecto.Changeset
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
        |> Statuses.update_status_timestamp(StudentStatus)
        |> Repo.update
        |> format_error(student)
    end
  end

  defp format_error({:ok, student}, _), do: {:ok, student}
  defp format_error({:error, changeset}, student), do: {:error, student, changeset}

end
