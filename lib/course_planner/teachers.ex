defmodule CoursePlanner.Teachers do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query
  alias Ecto.{Changeset, DateTime}

  @teachers from u in User, where: u.role == "Teacher" and is_nil(u.deleted_at)

  def all do
    Repo.all(@teachers)
  end

  def new(user, token) do
    %User{}
    |> User.changeset(user)
    |> Changeset.put_change(:reset_password_token, token)
    |> Changeset.put_change(:reset_password_sent_at, DateTime.utc())
    |> Changeset.put_change(:password, "fakepassword")
    |> Changeset.put_change(:role, "Teacher")
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      teacher ->
        teacher
        |> User.changeset(params, :update)
        |> add_timestamps()
        |> Repo.update
        |> format_error(teacher)
    end
  end

  defp add_timestamps(%{changes: %{status: "Active"}} = changeset) do
    Changeset.put_change(changeset, :activated_at, DateTime.utc())
  end

  defp add_timestamps(%{changes: %{status: "Frozen"}} = changeset) do
    Changeset.put_change(changeset, :froze_at, DateTime.utc())
  end

  defp add_timestamps(changeset), do: changeset

  defp format_error({:ok, teacher}, _), do: {:ok, teacher}
  defp format_error({:error, changeset}, teacher), do: {:error, teacher, changeset}

end
