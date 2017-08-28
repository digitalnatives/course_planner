defmodule CoursePlanner.SummaryControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup do
    user = insert(:coordinator)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  test "GET /summary", %{conn: conn} do
    conn = get conn, summary_path(conn, :show)
    assert html_response(conn, 200) =~ "Welcome to Phoenix"
  end
end
