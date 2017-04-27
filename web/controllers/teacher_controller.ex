defmodule CoursePlanner.TeacherController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias CoursePlanner.Router.Helpers
  import Ecto.Query
  alias CoursePlanner.Teachers

  def index(conn, _params) do
    render(conn, "index.html", teachers: Teachers.all())
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
end
