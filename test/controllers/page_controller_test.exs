defmodule CoursePlanner.PageControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup do
    user = build(:coordinator)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert redirected_to(conn, 301) == dashboard_path(conn, :show)
  end
end
