defmodule CoursePlanner.CoordinatorControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  alias CoursePlanner.Coordinators

  import CoursePlanner.Factory

  @valid_attrs %{name: "some content", email: "valid@email"}
  @invalid_attrs %{}

  setup do
    {:ok, conn: login_as(:coordinator)}
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, coordinator_path(conn, :index)
    assert html_response(conn, 200) =~ "Coordinator list"
  end

  test "shows chosen resource", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = get conn, coordinator_path(conn, :show, coordinator)
    assert html_response(conn, 200) =~ "Show coordinator"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, coordinator_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = get conn, coordinator_path(conn, :edit, coordinator)
    assert html_response(conn, 200) =~ "Edit coordinator"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = put conn, coordinator_path(conn, :update, coordinator), user: @valid_attrs
    assert redirected_to(conn) == coordinator_path(conn, :show, coordinator)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    coordinator = Repo.insert! %User{}
    conn = put conn, coordinator_path(conn, :update, coordinator), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit coordinator"
  end

  test "deletes chosen resource", %{conn: conn} do
    {:ok, coordinator} = Coordinators.new(@valid_attrs, "whatever")
    conn = delete conn, coordinator_path(conn, :delete, coordinator)
    assert redirected_to(conn) == coordinator_path(conn, :index)
    refute Repo.get(User, coordinator.id)
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

    coordinator = insert(:coordinator)

    conn = get student_conn, coordinator_path(student_conn, :edit, coordinator)
    assert html_response(conn, 403)

    conn = get teacher_conn, coordinator_path(teacher_conn, :edit, coordinator)
    assert html_response(conn, 403)

    conn = get volunteer_conn, coordinator_path(volunteer_conn, :edit, coordinator)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    coordinator = insert(:coordinator)

    conn = delete student_conn, coordinator_path(student_conn, :delete, coordinator.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, coordinator_path(teacher_conn, :delete, coordinator.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, coordinator_path(volunteer_conn, :delete, coordinator.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new class for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, coordinator_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, coordinator_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, coordinator_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create class for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    coordinator = insert(:coordinator)

    conn = post student_conn, coordinator_path(student_conn, :create), class: coordinator
    assert html_response(conn, 403)

    conn = post teacher_conn, coordinator_path(teacher_conn, :create), class: coordinator
    assert html_response(conn, 403)

    conn = post volunteer_conn, coordinator_path(volunteer_conn, :create), class: coordinator
    assert html_response(conn, 403)
  end

  test "does not update chosen coordinator for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    coordinator = Repo.insert! %User{}

    conn = put student_conn, coordinator_path(student_conn, :update, coordinator), coordinator: @valid_attrs
    assert html_response(conn, 403)

    conn = put teacher_conn, coordinator_path(teacher_conn, :update, coordinator), coordinator: @valid_attrs
    assert html_response(conn, 403)

    conn = put volunteer_conn, coordinator_path(volunteer_conn, :update, coordinator), coordinator: @valid_attrs
    assert html_response(conn, 403)
  end
end
