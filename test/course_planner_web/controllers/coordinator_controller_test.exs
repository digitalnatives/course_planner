defmodule CoursePlanner.CoordinatorControllerTest do
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
    conn = get conn, coordinator_path(conn, :index)
    assert html_response(conn, 200) =~ "Coordinators"
  end

  test "shows chosen resource", %{conn: conn} do
    coordinator = insert(:coordinator)
    conn = get conn, coordinator_path(conn, :show, coordinator)
    assert html_response(conn, 200) =~ "#{coordinator.name} #{coordinator.family_name}"
  end

  test "lists all entries on index for supervisor" do
    conn = login_as(:supervisor)
    conn = get conn, coordinator_path(conn, :index)
    assert html_response(conn, 200) =~ "Coordinators"
  end

  test "shows chosen resource for supervisor" do
    conn = login_as(:supervisor)
    coordinator = insert(:coordinator)
    conn = get conn, coordinator_path(conn, :show, coordinator)
    assert html_response(conn, 200) =~ "#{coordinator.name} #{coordinator.family_name}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, coordinator_path(conn, :show, -1)
    assert html_response(conn, 404)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    coordinator = insert(:coordinator, %{name: "Foo", family_name: "Bar"})
    conn = get conn, coordinator_path(conn, :edit, coordinator)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "renders page not found for editing inexistent resource", %{conn: conn} do
    conn = get conn, coordinator_path(conn, :edit, -1)
    assert html_response(conn, 404)
  end

  test "does not updates if the resource does not exist", %{conn: conn} do
    conn = put conn, coordinator_path(conn, :update, -1), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 404)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    coordinator = insert(:coordinator, %{})
    conn = put conn, coordinator_path(conn, :update, coordinator), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == coordinator_path(conn, :show, coordinator)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    coordinator = insert(:coordinator, %{name: "Foo", family_name: "Bar"})
    conn = put conn, coordinator_path(conn, :update, coordinator), %{"user" => %{"email" => "not email"}}
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "deletes chosen resource", %{conn: conn} do
    coordinator = insert(:coordinator)
    conn = delete conn, coordinator_path(conn, :delete, coordinator)
    assert redirected_to(conn) == coordinator_path(conn, :index)
    refute Repo.get(User, coordinator.id)
  end

  test "fails when doing a selfdeletion", %{conn: conn} do
    current_logged_in_coordinator = conn.assigns.current_user
    conn = delete conn, coordinator_path(conn, :delete, current_logged_in_coordinator)
    assert redirected_to(conn) == coordinator_path(conn, :index)
    assert get_flash(conn, "error") == "Coordinator cannot delete herself."
    assert Repo.get(User, current_logged_in_coordinator.id)
  end

  test "does not delete chosen resource when does not exist", %{conn: conn} do
    conn = delete conn, coordinator_path(conn, :delete, "-1")
    assert redirected_to(conn) == coordinator_path(conn, :index)
    assert get_flash(conn, "error") == "Coordinator was not found."
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, coordinator_path(conn, :new)
    assert html_response(conn, 200) =~ "New coordinator"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    coordinator = insert(:coordinator)

    conn = get student_conn, coordinator_path(student_conn, :show, coordinator)
    assert html_response(conn, 403)

    conn = get teacher_conn, coordinator_path(teacher_conn, :show, coordinator)
    assert html_response(conn, 403)

    conn = get volunteer_conn, coordinator_path(volunteer_conn, :show, coordinator)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, coordinator_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, coordinator_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, coordinator_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    coordinator = insert(:coordinator)

    conn = get student_conn, coordinator_path(student_conn, :edit, coordinator)
    assert html_response(conn, 403)

    conn = get teacher_conn, coordinator_path(teacher_conn, :edit, coordinator)
    assert html_response(conn, 403)

    conn = get volunteer_conn, coordinator_path(volunteer_conn, :edit, coordinator)
    assert html_response(conn, 403)

    conn = get supervisor_conn, coordinator_path(supervisor_conn, :edit, coordinator)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    coordinator = insert(:coordinator)

    conn = delete student_conn, coordinator_path(student_conn, :delete, coordinator.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, coordinator_path(teacher_conn, :delete, coordinator.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, coordinator_path(volunteer_conn, :delete, coordinator.id)
    assert html_response(conn, 403)

    conn = delete supervisor_conn, coordinator_path(supervisor_conn, :delete, coordinator.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new coordinator for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    conn = get student_conn, coordinator_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, coordinator_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, coordinator_path(volunteer_conn, :new)
    assert html_response(conn, 403)

    conn = get supervisor_conn, coordinator_path(supervisor_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create coordinator for coordinator user when data is invalid", %{conn: conn} do
    conn = post conn, coordinator_path(conn, :create), %{"user" => %{"email" => ""}}
    assert html_response(conn, 200) =~ "Something went wrong."
  end

  test "create coordinator for coordinator user", %{conn: conn} do
    conn = post conn, coordinator_path(conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == coordinator_path(conn, :index)
    assert get_flash(conn, "info") == "Coordinator created and notified by."
  end

  test "does not create coordinator for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    coordinator = insert(:coordinator)

    conn = post student_conn, coordinator_path(student_conn, :create), %{"user" => coordinator}
    assert html_response(conn, 403)

    conn = post teacher_conn, coordinator_path(teacher_conn, :create), %{"user" => coordinator}
    assert html_response(conn, 403)

    conn = post volunteer_conn, coordinator_path(volunteer_conn, :create), %{"user" => coordinator}
    assert html_response(conn, 403)
  end

  test "does not update chosen coordinator for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    coordinator = insert(:coordinator, %{})

    conn = put student_conn, coordinator_path(student_conn, :update, coordinator), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, coordinator_path(teacher_conn, :update, coordinator), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, coordinator_path(volunteer_conn, :update, coordinator), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end
end
