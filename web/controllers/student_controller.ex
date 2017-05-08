defmodule CoursePlanner.StudentController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias CoursePlanner.Students

  def index(conn, _params) do
    render(conn, "index.html", students: Students.all())
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

  def update(conn, %{"id" => id, "user" => params}) do
    case Students.update(id, params) do
      {:ok, student} ->
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

end
