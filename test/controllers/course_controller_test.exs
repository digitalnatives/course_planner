defmodule CoursePlanner.CourseControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.User
  alias CoursePlanner.Course

  @valid_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, status: "Planned", syllabus: "some content"}
  @invalid_attrs %{}
  @user %User{
    name: "Test User",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret"}

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
        |> assign(:current_user, @user)
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, course_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing courses"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, course_path(conn, :new)
    assert html_response(conn, 200) =~ "New course"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: @valid_attrs
    assert redirected_to(conn) == course_path(conn, :index)
    assert Repo.get_by(Course, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: @invalid_attrs
    assert html_response(conn, 200) =~ "New course"
  end

  test "shows chosen resource", %{conn: conn} do
    course = Repo.insert! %Course{}
    conn = get conn, course_path(conn, :show, course)
    assert html_response(conn, 200) =~ "Show course"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, course_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    course = Repo.insert! %Course{}
    conn = get conn, course_path(conn, :edit, course)
    assert html_response(conn, 200) =~ "Edit course"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    course = Repo.insert! %Course{}
    conn = put conn, course_path(conn, :update, course), course: @valid_attrs
    assert redirected_to(conn) == course_path(conn, :show, course)
    assert Repo.get_by(Course, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    course = Repo.insert! %Course{}
    conn = put conn, course_path(conn, :update, course), course: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit course"
  end

  test "deletes chosen resource", %{conn: conn} do
    course = Repo.insert! %Course{}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    refute Repo.get(Course, course.id)
  end

  test "does not create resource and renders errors when data number_of_sessions is negative", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | number_of_sessions: -1}
    assert html_response(conn, 200) =~ "New course"
  end

  test "does not create resource and renders errors when data number_of_sessions is zero", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | number_of_sessions: 0}
    assert html_response(conn, 200) =~ "New course"
  end

  test "does not create resource and renders errors when data number_of_sessions is too big", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | number_of_sessions: 100_000_000}
    assert html_response(conn, 200) =~ "New course"
  end

  test "does not create resource and renders errors when data value of status is not valid", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | status: "random"}
    assert html_response(conn, 200) =~ "New course"
  end

  test "creates resource and redirects when data is valid and status is Planned", %{conn: conn} do
    new_attrs = %{@valid_attrs | status: "Planned"}
    conn = post conn, course_path(conn, :create), course: new_attrs
    assert redirected_to(conn) == course_path(conn, :index)
    assert Repo.get_by(Course, new_attrs)
  end

  test "creates resource and redirects when data is valid and status is Active", %{conn: conn} do
    new_attrs = %{@valid_attrs | status: "Active"}
    conn = post conn, course_path(conn, :create), course: new_attrs
    assert redirected_to(conn) == course_path(conn, :index)
    assert Repo.get_by(Course, new_attrs)
  end

end
