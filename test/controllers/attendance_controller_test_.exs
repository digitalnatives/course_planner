defmodule CoursePlanner.AttendanceControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Attendance
  @valid_attrs %{attendance_type: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, attendance_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing attendances"
  end
end
