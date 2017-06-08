defmodule CoursePlanner.DashboardControllerTest do
  use CoursePlanner.ConnCase

  import CoursePlanner.Factory

  setup do
    user = build(:coordinator)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  test "GET /dashboard", %{conn: conn} do
    conn = get conn, dashboard_path(conn, :show)
    assert html_response(conn, 200) =~ "Welcome to Phoenix"
  end
end
