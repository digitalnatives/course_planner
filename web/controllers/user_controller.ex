defmodule CoursePlanner.UserController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.{User, Users}
  require Logger

  def index(conn, _params) do
    query = from u in User, where: is_nil(u.deleted_at)
    users = Repo.all(query)
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    case Users.get(id) do
      {:ok, user} -> render(conn, "show.html", user: user)
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
    end
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
        Users.notify_user(user, current_user, :user_modified, user_path(conn, :show, user))
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
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
