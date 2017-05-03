defmodule CoursePlanner.Coordinators do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query
  alias Ecto.{Changeset, DateTime}

  @coordinators from u in User, where: u.role == "Coordinator" and is_nil(u.deleted_at)

  def all do
    Repo.all(@coordinators)
  end

  def new(user, token) do
    %User{}
    |> User.changeset(user)
    |> Changeset.put_change(:reset_password_token, token)
    |> Changeset.put_change(:reset_password_sent_at, DateTime.utc())
    |> Changeset.put_change(:password, "fakepassword")
    |> Changeset.put_change(:role, "Coordinator")
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      coordinator ->
        coordinator
        |> User.changeset(params, :update)
        |> add_timestamps()
        |> Repo.update
        |> format_error(coordinator)
    end
  end

  defp add_timestamps(%{changes: %{status: "Active"}} = changeset) do
    Changeset.put_change(changeset, :activated_at, DateTime.utc())
  end

  defp add_timestamps(%{changes: %{status: "Frozen"}} = changeset) do
    Changeset.put_change(changeset, :froze_at, DateTime.utc())
  end

  defp add_timestamps(changeset), do: changeset

  defp format_error({:ok, coordinator}, _), do: {:ok, coordinator}
  defp format_error({:error, changeset}, coordinator), do: {:error, coordinator, changeset}

end
