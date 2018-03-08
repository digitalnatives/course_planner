defmodule CoursePlanner.FallbackControllerTest do
  use CoursePlannerWeb.ConnCase

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  test "not found error", %{conn: conn} do
    conn = CoursePlannerWeb.FallbackController.call(conn, {:error, :not_found})
    assert html_response(conn, 404)
  end

  test "not forbidden error", %{conn: conn} do
    conn = CoursePlannerWeb.FallbackController.call(conn, {:error, :forbidden})
    assert html_response(conn, 403)
  end

  test "not generic error", %{conn: conn} do
    conn = CoursePlannerWeb.FallbackController.call(conn, :whatever_happens)
    assert html_response(conn, 500)
  end
end
