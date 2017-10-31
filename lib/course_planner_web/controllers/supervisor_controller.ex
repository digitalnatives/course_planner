defmodule CoursePlannerWeb.SupervisorController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.{Accounts.Users, Accounts.User,
                       Accounts.Supervisors,
                       Auth.Helper}
  alias CoursePlannerWeb.{Router.Helpers, Auth.UserEmail}

  import Canary.Plugs
  plug :authorize_resource, model: User

  def index(conn, _params) do
    render(conn, "index.html", supervisors: Supervisors.all())
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user}) do
    token = Helper.get_random_token_with_length 48
    url = Helpers.password_url(conn, :edit, token)
    case Supervisors.new(user, token) do
      {:ok, supervisor} ->
        UserEmail.send_user_email(:welcome, supervisor, url)
        conn
        |> put_flash(:info, "Supervisor created and notified by.")
        |> redirect(to: supervisor_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    supervisor = Repo.get!(User, id)
    render(conn, "show.html", supervisor: supervisor)
  end

  def edit(conn, %{"id" => id}) do
    supervisor = Repo.get!(User, id)
    changeset = User.changeset(supervisor)
    render(conn, "edit.html", supervisor: supervisor, changeset: changeset)
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "user" => params}) do
    case Supervisors.update(id, params) do
      {:ok, supervisor} ->
        Users.notify_user(supervisor,
          current_user,
          :user_modified,
          supervisor_url(conn, :show, supervisor))
        conn
        |> put_flash(:info, "Supervisor updated successfully.")
        |> redirect(to: supervisor_path(conn, :show, supervisor))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
      {:error, supervisor, changeset} ->
        render(conn, "edit.html", supervisor: supervisor, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: %User{id: current_user_id}}} = conn, %{"id" => id}) do
    case Users.delete(id, current_user_id) do
      {:ok, _supervisor} ->
        conn
        |> put_flash(:info, "Supervisor deleted successfully.")
        |> redirect(to: supervisor_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Supervisor was not found.")
        |> redirect(to: supervisor_path(conn, :index))
      {:error, :self_deletion} ->
        conn
        |> put_flash(:error, "Supervisor cannot delete herself.")
        |> redirect(to: supervisor_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: supervisor_path(conn, :index))
    end
  end
end
