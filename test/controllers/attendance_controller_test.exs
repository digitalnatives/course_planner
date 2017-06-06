defmodule CoursePlanner.AttendanceControllerTest do
  use CoursePlanner.ConnCase

  import CoursePlanner.Factory
  alias CoursePlanner.{Attendance, User}

  @valid_insert_attrs %{offered_course: nil, date: %{day: 17, month: 4, year: 2010}, starting_at: %{hour: 14, min: 0, sec: 0}, finishes_at: %{hour: 15, min: 0, sec: 0}, status: "Planned"}

  defp create_attendance(students) do
    offered_course = insert(:offered_course, %{students: students})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course, status: "Active"}
    class = insert(:class, class_attrs)

    Enum.map(students, fn(student)->
         insert(:attendance, %{class: class, student: student})
       end)

    offered_course
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "lists all entries on index for coordinator", %{conn: _conn} do
    user_conn = login_as(:coordinator)
    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 200) =~ "Listing Course for attendance"
  end

  test "lists all entries on index for teacher", %{conn: _conn} do
    user_conn = login_as(:teacher)
    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 200) =~ "Listing Course for attendance"
  end

  test "lists all entries on index for student", %{conn: _conn} do
    user_conn = login_as(:student)
    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 200) =~ "Listing Course for attendance"
  end

  test "do not list anything for volunteer", %{conn: _conn} do
    user_conn = login_as(:volunteer)
    assert_raise Phoenix.ActionClauseError, fn ->
      get user_conn, attendance_path(user_conn, :index)
    end
  end

  test "shows chosen resource by user coordinator", %{conn: _conn} do
    user_conn = login_as(:coordinator)
    students = insert_list(3, :student)
    offered_course = create_attendance(students)

    conn = get user_conn, attendance_path(user_conn, :show, offered_course.id)
    assert html_response(conn, 200) =~ "Show attendance for"
  end

  test "shows chosen resource by user teacher", %{conn: _conn} do
    user_conn = login_as(:teacher)
    students = insert_list(3, :student)
    offered_course = create_attendance(students)

    conn = get user_conn, attendance_path(user_conn, :show, offered_course.id)
    assert html_response(conn, 200) =~ "Show attendance for"
  end

  test "shows chosen resource by user student", %{conn: _conn} do
    user_conn = login_as(:student)

    student = Repo.get!(User, user_conn.assigns.current_user.id)
    offered_course = create_attendance([student])

    conn = get user_conn, attendance_path(user_conn, :show, offered_course.id)
    assert html_response(conn, 200) =~ "Show attendance for"
  end

  test "does not show chosen resource by user volunteer", %{conn: _conn} do
    user_conn = login_as(:volunteer)

    attendance = Repo.insert! %Attendance{}
    assert_raise Phoenix.ActionClauseError, fn ->
      get user_conn, attendance_path(user_conn, :show, attendance)
    end
  end
end
