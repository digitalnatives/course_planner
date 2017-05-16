defmodule CoursePlanner.OfferedCourseControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, Terms, User}
  def valid_attrs do
    %{
      term_id: term().id,
      course_id: course("Course1").id
    }
  end

  def invalid_attrs do
    %{course_id: -1}
  end

  defp term do
    {:ok, term} = Terms.create(
      %{
        name: "Name",
        start_date: "2017-01-01",
        end_date: "2017-01-31",
        status: "Active"
      })
    term
  end

  defp course(name) do
    Repo.insert!(
      Course.changeset(
        %Course{},
        %{
          name: name,
          description: "Description",
          number_of_sessions: 1,
          session_duration: "01:00:00",
          status: "Active"
        }))
  end

  setup do
    user =
      %User{
        name: "Test User",
        email: "testuser@example.com",
        password: "secret",
        password_confirmation: "secret"
      }

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end


  test "lists all entries on index", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing offered courses by term"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :new)
    assert html_response(conn, 200) =~ "New offered course"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: attrs
    assert redirected_to(conn) == offered_course_path(conn, :index)
    assert Repo.get_by(OfferedCourse, attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, offered_course_path(conn, :create), offered_course: invalid_attrs()
    assert html_response(conn, 200) =~ "New offered course"
  end

  test "shows chosen resource", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 200) =~ "Show offered course"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, offered_course_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = get conn, offered_course_path(conn, :edit, offered_course)
    assert html_response(conn, 200) =~ "Edit offered course"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    attrs = valid_attrs()
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: attrs
    assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
    assert Repo.get_by(OfferedCourse, attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: invalid_attrs()
    assert html_response(conn, 200) =~ "Edit offered course"
  end

  test "deletes chosen resource", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = delete conn, offered_course_path(conn, :delete, offered_course)
    assert redirected_to(conn) == offered_course_path(conn, :index)
    refute Repo.get(OfferedCourse, offered_course.id)
  end
end
