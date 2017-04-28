defmodule CoursePlanner.CoordinatorController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias CoursePlanner.Router.Helpers
  import Ecto.Query
  alias CoursePlanner.Coordinators

  def index(conn, _params) do
    render(conn, "index.html", coordinators: Coordinators.all())
  end

  def show(conn, %{"id" => id}) do
    coordinator = Repo.get!(User, id)
    render(conn, "show.html", coordinator: coordinator)
  end

  def edit(conn, %{"id" => id}) do
    coordinator = Repo.get!(User, id)
    changeset = User.changeset(coordinator)
    render(conn, "edit.html", coordinator: coordinator, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    case Coordinators.update(id, params) do
      {:ok, coordinator} ->
        conn
        |> put_flash(:info, "Coordinator updated successfully.")
        |> redirect(to: coordinator_path(conn, :show, coordinator))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, coordinator, changeset} ->
        render(conn, "edit.html", coordinator: coordinator, changeset: changeset)
    end
  end
end
