defmodule CoursePlanner.StudentController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias CoursePlanner.Router.Helpers
  import Ecto.Query

  def index(conn, _params) do
    query = from u in User, where: u.role == "Student"
    students = Repo.all(query)
    render(conn, "index.html", students: students)
  end
end
