defmodule CoursePlannerWeb.VolunteerController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.{User, Volunteers, Users}
  alias CoursePlannerWeb.Router.Helpers
  alias Coherence.ControllerHelpers

  import Canary.Plugs
  plug :authorize_resource, model: User

  def index(conn, _params) do
    render(conn, "index.html", volunteers: Volunteers.all())
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user}) do
    token = ControllerHelpers.random_string 48
    url = Helpers.password_url(conn, :edit, token)
    case Volunteers.new(user, token) do
      {:ok, volunteer} ->
        ControllerHelpers.send_user_email(:welcome, volunteer, url)
        conn
        |> put_flash(:info, "Volunteer created and notified by.")
        |> redirect(to: volunteer_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    volunteer =
      User
      |> Repo.get!(id)

    tasks = Volunteers.get_tasks(volunteer)

    render(conn, "show.html", volunteer: volunteer, tasks: tasks)
  end

  def edit(conn, %{"id" => id}) do
    volunteer = Repo.get!(User, id)
    changeset = User.changeset(volunteer)
    render(conn, "edit.html", volunteer: volunteer, changeset: changeset)
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "user" => params}) do
    case Volunteers.update(id, params) do
      {:ok, volunteer} ->
        Users.notify_user(volunteer,
          current_user,
          :user_modified,
          volunteer_url(conn, :show, volunteer))
        conn
        |> put_flash(:info, "Volunteer updated successfully.")
        |> redirect(to: volunteer_path(conn, :show, volunteer))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
      {:error, volunteer, changeset} ->
        render(conn, "edit.html", volunteer: volunteer, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Users.delete(id) do
      {:ok, _volunteer} ->
        conn
        |> put_flash(:info, "Volunteer deleted successfully.")
        |> redirect(to: volunteer_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Volunteer was not found.")
        |> redirect(to: volunteer_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: volunteer_path(conn, :index))
    end
  end
end
