defmodule CoursePlanner.VolunteerController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.{User, Volunteers, Router.Helpers, Users, Notifier}
  alias Coherence.ControllerHelpers

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
        ControllerHelpers.send_user_email :password, volunteer, url
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
    volunteer = Repo.get!(User, id)
    render(conn, "show.html", volunteer: volunteer)
  end

  def edit(conn, %{"id" => id}) do
    volunteer = Repo.get!(User, id)
    changeset = User.changeset(volunteer)
    render(conn, "edit.html", volunteer: volunteer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    case Volunteers.update(id, params) do
      {:ok, volunteer} ->
        Notifier.notify_user(volunteer, :user_modified)
        conn
        |> put_flash(:info, "Volunteer updated successfully.")
        |> redirect(to: volunteer_path(conn, :show, volunteer))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
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
