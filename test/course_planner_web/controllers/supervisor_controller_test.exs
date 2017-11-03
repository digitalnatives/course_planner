defmodule CoursePlanner.SupervisorControllerTest do
  use CoursePlannerWeb.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.Accounts.User

  import CoursePlanner.Factory

  setup do
    {:ok, conn: login_as(:coordinator)}
  end

  defp login_as(user_type) do
    user_type
    |> insert()
    |> guardian_login_html()
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, supervisor_path(conn, :index)
    assert html_response(conn, 200) =~ "Supervisors"
  end

  test "shows chosen resource", %{conn: conn} do
    supervisor = insert(:supervisor)
    conn = get conn, supervisor_path(conn, :show, supervisor)
    assert html_response(conn, 200) =~ "#{supervisor.name} #{supervisor.family_name}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, supervisor_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    supervisor = insert(:supervisor, %{name: "Foo", family_name: "Bar"})
    conn = get conn, supervisor_path(conn, :edit, supervisor)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "does not updates if the resource does not exist", %{conn: conn} do
    conn = put conn, supervisor_path(conn, :update, -1), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 404)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    supervisor = insert(:supervisor, %{})
    conn = put conn, supervisor_path(conn, :update, supervisor), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == supervisor_path(conn, :show, supervisor)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    supervisor = insert(:supervisor, %{name: "Foo", family_name: "Bar"})
    conn = put conn, supervisor_path(conn, :update, supervisor), %{"user" => %{"email" => "not email"}}
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "deletes chosen resource", %{conn: conn} do
    supervisor = insert(:supervisor)
    conn = delete conn, supervisor_path(conn, :delete, supervisor)
    assert redirected_to(conn) == supervisor_path(conn, :index)
    refute Repo.get(User, supervisor.id)
  end

  test "does not delete chosen resource when does not exist", %{conn: conn} do
    conn = delete conn, supervisor_path(conn, :delete, "-1")
    assert redirected_to(conn) == supervisor_path(conn, :index)
    assert get_flash(conn, "error") == "Supervisor was not found."
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, supervisor_path(conn, :new)
    assert html_response(conn, 200) =~ "New supervisor"
  end

  test "does not shows chosen resource for non supervisor user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    supervisor = insert(:supervisor)

    conn = get student_conn, supervisor_path(student_conn, :show, supervisor)
    assert html_response(conn, 403)

    conn = get teacher_conn, supervisor_path(teacher_conn, :show, supervisor)
    assert html_response(conn, 403)

    conn = get volunteer_conn, supervisor_path(volunteer_conn, :show, supervisor)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non supervisor user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, supervisor_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, supervisor_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, supervisor_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    supervisor = insert(:supervisor)

    conn = get student_conn, supervisor_path(student_conn, :edit, supervisor)
    assert html_response(conn, 403)

    conn = get teacher_conn, supervisor_path(teacher_conn, :edit, supervisor)
    assert html_response(conn, 403)

    conn = get volunteer_conn, supervisor_path(volunteer_conn, :edit, supervisor)
    assert html_response(conn, 403)

    conn = get supervisor_conn, supervisor_path(supervisor_conn, :edit, supervisor)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    supervisor = insert(:supervisor)

    conn = delete student_conn, supervisor_path(student_conn, :delete, supervisor.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, supervisor_path(teacher_conn, :delete, supervisor.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, supervisor_path(volunteer_conn, :delete, supervisor.id)
    assert html_response(conn, 403)

    conn = delete supervisor_conn, supervisor_path(supervisor_conn, :delete, supervisor.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new supervisor for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    conn = get student_conn, supervisor_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, supervisor_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, supervisor_path(volunteer_conn, :new)
    assert html_response(conn, 403)

    conn = get supervisor_conn, supervisor_path(supervisor_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create supervisor for coordinator user when data is invalid", %{conn: conn} do
    conn = post conn, supervisor_path(conn, :create), %{"user" => %{"email" => ""}}
    assert html_response(conn, 200) =~ "Something went wrong."
  end

  test "create supervisor for coordinator user", %{conn: conn} do
    conn = post conn, supervisor_path(conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == supervisor_path(conn, :index)
    assert get_flash(conn, "info") == "Supervisor created and notified by."
  end

  test "does not create supervisor for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    supervisor = insert(:supervisor)

    conn = post student_conn, supervisor_path(student_conn, :create), %{"user" => supervisor}
    assert html_response(conn, 403)

    conn = post teacher_conn, supervisor_path(teacher_conn, :create), %{"user" => supervisor}
    assert html_response(conn, 403)

    conn = post volunteer_conn, supervisor_path(volunteer_conn, :create), %{"user" => supervisor}
    assert html_response(conn, 403)

    conn = post supervisor_conn, supervisor_path(supervisor_conn, :create), %{"user" => supervisor}
    assert html_response(conn, 403)
  end

  test "does not update chosen supervisor for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    supervisor = insert(:supervisor, %{})

    conn = put student_conn, supervisor_path(student_conn, :update, supervisor), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, supervisor_path(teacher_conn, :update, supervisor), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, supervisor_path(volunteer_conn, :update, supervisor), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put supervisor_conn, supervisor_path(supervisor_conn, :update, supervisor), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end
end
