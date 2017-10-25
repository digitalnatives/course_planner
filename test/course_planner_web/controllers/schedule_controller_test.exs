defmodule CoursePlanner.ScheduleControllerTest do
  use CoursePlannerWeb.ConnCase
  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    conn =
      role
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  @tag user_role: :coordinator
  test "renders schedule page for coordinator", %{conn: conn} do
    conn = get conn, schedule_path(conn, :show)
    assert html_response(conn, 200)
  end

  @tag user_role: :teacher
  test "renders schedule page for teacher", %{conn: conn} do
    conn = get conn, schedule_path(conn, :show)
    assert html_response(conn, 200)
  end

  @tag user_role: :student
  test "renders schedule page for student", %{conn: conn} do
    conn = get conn, schedule_path(conn, :show)
    assert html_response(conn, 200)
  end

  @tag user_role: :volunteer
  test "renders schedule page for vounteer", %{conn: conn} do
    conn = get conn, schedule_path(conn, :show)
    assert html_response(conn, 200)
  end
end
