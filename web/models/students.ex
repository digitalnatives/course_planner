defmodule CoursePlanner.Students do
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query

  @students from u in User, where: u.role == "Student" and is_nil(u.deleted_at)

  def all() do
    Repo.all(@students)
  end

  def update(id, params) do
    case Repo.get(User, id) do
      student ->
        student
        |> User.changeset(params, :update)
        |> Repo.update
        |> format_error(student)
      nil -> {:error, :not_found}
    end
  end

  defp format_error({:ok, student}, _), do: {:ok, student}
  defp format_error({:error, changeset}, student), do: {:error, student, changeset}

end
