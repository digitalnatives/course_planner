defmodule CoursePlanner.CoordinatorController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.{User, Coordinators, Router.Helpers, Users}
  alias Coherence.ControllerHelpers

  def index(conn, _params) do
    render(conn, "index.html", coordinators: Coordinators.all())
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user}) do
    token = ControllerHelpers.random_string 48
    url = Helpers.password_url(conn, :edit, token)
    case Coordinators.new(user, token) do
      {:ok, coordinator} ->
        ControllerHelpers.send_user_email :password, coordinator, url
        conn
        |> put_flash(:info, "Coordinator created and notified by.")
        |> redirect(to: coordinator_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", changeset: changeset)
    end
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

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "user" => params}) do
    case Coordinators.update(id, params) do
      {:ok, coordinator} ->
        Users.notify_user(coordinator, current_user, :user_modified)
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

  def delete(conn, %{"id" => id}) do
    case Users.delete(id) do
      {:ok, _coordinator} ->
        conn
        |> put_flash(:info, "Coordinator deleted successfully.")
        |> redirect(to: coordinator_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Coordinator was not found.")
        |> redirect(to: coordinator_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: coordinator_path(conn, :index))
    end
  end
end
