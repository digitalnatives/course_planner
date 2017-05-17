defmodule CoursePlanner.TeacherController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.{User, Teachers, Router.Helpers, Users, Notifier}
  alias Coherence.ControllerHelpers

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
        ControllerHelpers.send_user_email :password, teacher, url
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
    teacher = Repo.get!(User, id)
    render(conn, "show.html", teacher: teacher)
  end

  def edit(conn, %{"id" => id}) do
    teacher = Repo.get!(User, id)
    changeset = User.changeset(teacher)
    render(conn, "edit.html", teacher: teacher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    case Teachers.update(id, params) do
      {:ok, teacher} ->
        Notifier.notify_user(teacher, :user_modified)
        conn
        |> put_flash(:info, "Teacher updated successfully.")
        |> redirect(to: teacher_path(conn, :show, teacher))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, teacher, changeset} ->
        render(conn, "edit.html", teacher: teacher, changeset: changeset)
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
