defmodule CoursePlanner.StudentController do
  @moduledoc false
  use CoursePlanner.Web, :controller
  alias CoursePlanner.{User, Students, Router.Helpers, Users}
  alias Coherence.ControllerHelpers

  import Canary.Plugs
  plug :authorize_resource, model: User

  def index(conn, _params) do
    render(conn, "index.html", students: Students.all())
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user}) do
    token = ControllerHelpers.random_string 48
    url = Helpers.password_url(conn, :edit, token)
    case Students.new(user, token) do
      {:ok, student} ->
        ControllerHelpers.send_user_email :password, student, url
        conn
        |> put_flash(:info, "Student created and notified by.")
        |> redirect(to: student_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    student = Repo.get!(User, id)
    render(conn, "show.html", student: student)
  end

  def edit(conn, %{"id" => id}) do
    student = Repo.get!(User, id)
    changeset = User.changeset(student)
    render(conn, "edit.html", student: student, changeset: changeset)
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "user" => params}) do
    case Students.update(id, params) do
      {:ok, student} ->
        Users.notify_user(student, current_user, :user_modified, student_url(conn, :show, student))
        conn
        |> put_flash(:info, "Student updated successfully.")
        |> redirect(to: student_path(conn, :show, student))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, student, changeset} ->
        render(conn, "edit.html", student: student, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Users.delete(id) do
      {:ok, _student} ->
        conn
        |> put_flash(:info, "Student deleted successfully.")
        |> redirect(to: student_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Student was not found.")
        |> redirect(to: student_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: student_path(conn, :index))
    end
  end
end
