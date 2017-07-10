defmodule CoursePlanner.CourseMatrixController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.OfferedCourses

  def index(conn, %{"term_id" => term_id}) do
    render(conn, "index.html",
      courses: OfferedCourses.find_by_term_id(term_id) ,
      matrix: OfferedCourses.student_matrix(term_id))
  end
end
