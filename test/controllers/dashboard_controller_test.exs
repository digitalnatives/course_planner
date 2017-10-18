defmodule CoursePlanner.DashboardControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup do
    conn =
      :coordinator
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  test "GET /dashboard", %{conn: conn} do
    conn = get conn, dashboard_path(conn, :show)
    assert html_response(conn, 200) =~ "Welcome to Phoenix"
  end
end
