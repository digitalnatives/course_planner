defmodule CoursePlanner.UserController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.{User, Users}
  require Logger

  import Canary.Plugs
  plug :authorize_resource, model: User

  def index(conn, _params) do
    render(conn, "index.html", users: Users.all())
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        Users.notify_user(user, current_user, :user_modified, user_show_url(user))

        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: dashboard_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Users.delete(id) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "User was not found.")
        |> redirect(to: user_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: user_path(conn, :index))
    end
  end
end
