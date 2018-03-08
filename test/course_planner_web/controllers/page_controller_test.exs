defmodule CoursePlanner.PageControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup do
    conn =
      :coordinator
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert redirected_to(conn, 301) == dashboard_path(conn, :show)
  end
end
