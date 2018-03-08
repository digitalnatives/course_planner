defmodule CoursePlanner.MatrixControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup do
    {:ok, conn: login_as(:coordinator)}
  end

  defp login_as(user_type) do
    user_type
    |> insert()
    |> guardian_login_html()
  end

  test "request index page", %{conn: conn} do
    conn = get conn, term_course_matrix_path(conn, :index, 1)
    assert html_response(conn, 200) =~ "Course Conflict"
  end
end
