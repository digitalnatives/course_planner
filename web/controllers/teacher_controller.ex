defmodule CoursePlanner.TeacherController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias CoursePlanner.Router.Helpers
  import Ecto.Query
  alias CoursePlanner.Teachers

  def index(conn, _params) do
    render(conn, "index.html", teachers: Teachers.all())
  end
end
