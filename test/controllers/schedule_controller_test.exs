defmodule CoursePlanner.ScheduleControllerTest do
  use CoursePlanner.ConnCase

  test "renders schedule page", %{conn: conn} do
    conn = get conn, schedule_path(conn, :show)
    assert html_response(conn, 200)
  end
end
