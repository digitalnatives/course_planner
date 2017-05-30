defmodule CoursePlanner.AttendanceControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Attendance
  @valid_attrs %{attendance_type: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, attendance_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing attendances"
  end

  test "shows chosen resource", %{conn: conn} do
    attendance = Repo.insert! %Attendance{}
    conn = get conn, attendance_path(conn, :show, attendance)
    assert html_response(conn, 200) =~ "Show attendance"
  end
end
