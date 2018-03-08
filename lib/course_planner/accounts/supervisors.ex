defmodule CoursePlanner.Accounts.Supervisors do
  @moduledoc false
  import Ecto.Query
  alias CoursePlanner.{Repo, Accounts.User, Accounts.Users}

  @supervisors from u in User, where: u.role == "Supervisor",
    order_by: [u.name, u.family_name, u.nickname]

  def all do
    Repo.all(@supervisors)
  end

  def new(user, token) do
    user
    |> Map.put("role", "Supervisor")
    |> Users.new_user(token)
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      supervisor ->
        supervisor
        |> User.changeset(params, :update)
        |> Repo.update
        |> format_error(supervisor)
    end
  end

  defp format_error({:ok, supervisor}, _), do: {:ok, supervisor}
  defp format_error({:error, changeset}, supervisor), do: {:error, supervisor, changeset}

end
