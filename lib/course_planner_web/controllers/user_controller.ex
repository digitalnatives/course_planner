defmodule CoursePlannerWeb.UserController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.{Accounts.User, Accounts.Users}
  alias CoursePlannerWeb.Router.Helpers
  alias Coherence.ControllerHelpers
  require Logger

  import Canary.Plugs
  plug :authorize_resource, model: User, non_id_actions: [:notify]

  def index(conn, _params) do
    render(conn, "index.html", users: Users.all())
  end

  def show(conn, %{"id" => id}) do
    case Users.get(id) do
      {:ok, user} -> render(conn, "show.html", user: user)
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(
    %{assigns: %{current_user: current_user}} = conn,
    %{"id" => id, "user" => user_params}) do

    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        Users.notify_user(user, current_user, :user_modified, user_show_url(user))

        if conn.assigns.current_user.role === "Coordinator" do
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: user_path(conn, :show, user))
        else
          conn
          |> put_flash(:info, "Your profile has been updated successfully.")
          |> redirect(to: dashboard_path(conn, :show))
        end
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

  def notify(conn, _params) do
    Users.notify_all()
    conn
    |> put_flash(:info, "Users notified successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def resend_email(conn, %{"id" => id}) do
    case Users.get(id) do
      {:ok, user} ->
        token = ControllerHelpers.random_string 48
        params = %{reset_password_token: token, reset_password_sent_at: Timex.now()}
        changeset = User.changeset(user, params)
        updated_user = Repo.update!(changeset)

        url = Helpers.password_url(conn, :edit, token)
        ControllerHelpers.send_user_email(:welcome, updated_user, url)

        conn
        |> put_flash(:info, "Reset e-mail sent.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
    end
  end
end
