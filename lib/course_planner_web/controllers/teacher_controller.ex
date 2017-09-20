defmodule CoursePlannerWeb.TeacherController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.{Accounts.User, Accounts.Teachers, Accounts.Users}
  alias CoursePlannerWeb.Router.Helpers
  alias Coherence.ControllerHelpers

  import Canary.Plugs
  plug :authorize_resource, model: User
  action_fallback CoursePlannerWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.html", teachers: Teachers.all())
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user}) do
    token = ControllerHelpers.random_string 48
    url = Helpers.password_url(conn, :edit, token)
    case Teachers.new(user, token) do
      {:ok, teacher} ->
        ControllerHelpers.send_user_email(:welcome, teacher, url)
        conn
        |> put_flash(:info, "Teacher created and notified by.")
        |> redirect(to: teacher_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, teacher} <- Users.get(id) do
      render(conn, "show.html", teacher: teacher)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, teacher} <- Users.get(id),
         changeset   <- User.changeset(teacher)
    do
      render(conn, "edit.html", teacher: teacher, changeset: changeset)
    end
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "user" => params}) do
    case Teachers.update(id, params) do
      {:ok, teacher} ->
        Users.notify_user(teacher, current_user, :user_modified, teacher_url(conn, :show, teacher))
        conn
        |> put_flash(:info, "Teacher updated successfully.")
        |> redirect(to: teacher_path(conn, :show, teacher))
      {:error, teacher, changeset} ->
        render(conn, "edit.html", teacher: teacher, changeset: changeset)
      error -> error
    end
  end

  def delete(conn, %{"id" => id}) do
    case Users.delete(id) do
      {:ok, _teacher} ->
        conn
        |> put_flash(:info, "Teacher deleted successfully.")
        |> redirect(to: teacher_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Teacher was not found.")
        |> redirect(to: teacher_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: teacher_path(conn, :index))
    end
  end
end
