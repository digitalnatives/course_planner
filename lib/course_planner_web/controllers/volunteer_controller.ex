defmodule CoursePlannerWeb.VolunteerController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.{Accounts.User, Accounts.Volunteers, Accounts.Users}
  alias CoursePlannerWeb.Router.Helpers
  alias Coherence.ControllerHelpers

  import Canary.Plugs
  plug :authorize_resource, model: User
  action_fallback CoursePlannerWeb.FallbackController

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
    with {:ok, volunteer} <- Users.get(id),
         tasks            <- Volunteers.get_tasks(volunteer)
    do
      render(conn, "show.html", volunteer: volunteer, tasks: tasks)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, volunteer} <- Users.get(id),
         changeset   <- User.changeset(volunteer)
    do
      render(conn, "edit.html", volunteer: volunteer, changeset: changeset)
    end
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
      {:error, volunteer, changeset} ->
        render(conn, "edit.html", volunteer: volunteer, changeset: changeset)
      error -> error
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
