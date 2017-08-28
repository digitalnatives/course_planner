defmodule CoursePlanner.UserControllerTest do
  use CoursePlannerWeb.ConnCase
  alias CoursePlanner.Repo
  alias CoursePlanner.User

  import CoursePlanner.Factory

  setup do
    {:ok, conn: login_as(:coordinator)}
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "All users"
  end

  test "shows chosen resource", %{conn: conn} do
    user = insert(:student)
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~
      Enum.join([user.name, user.family_name], " ")
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, user_path(conn, :show, -1)
    assert html_response(conn, 404)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = insert(:student, %{name: "Foo", family_name: "Bar"})
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:student, %{name: "Foo", family_name: "Bar"})
    conn = put conn, user_path(conn, :update, user), %{"user" => %{"email" => "not email"}}
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student)

    conn = get student_conn, user_path(student_conn, :show, user)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :show, user)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :show, user)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, user_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student)

    conn = get student_conn, user_path(student_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :edit, user)
    assert html_response(conn, 403)
  end

  test "does not delete a non-existing user", %{conn: conn} do
    conn = delete conn, user_path(conn, :delete, -1)
    assert redirected_to(conn) == user_path(conn, :index)
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "User was not found."
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student)

    conn = delete student_conn, user_path(student_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, user_path(teacher_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, user_path(volunteer_conn, :delete, user.id)
    assert html_response(conn, 403)
  end

  test "does not update chosen user for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    user = insert(:student, %{})

    conn = put student_conn, user_path(student_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, user_path(teacher_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, user_path(volunteer_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end

  test "shows the user himself" do
    user_conn = login_as(:user)
    user = user_conn.assigns.current_user

    conn = get user_conn, user_path(user_conn, :show, user)
    assert html_response(conn, 200)
  end

  test "edit the user himself" do
    user = insert(:user, name: "Foo", family_name: "Bar")
    user_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)

    conn = get user_conn, user_path(user_conn, :edit, user)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "coordinator updates his profile" do
    user_conn = login_as(:coordinator)
    user = user_conn.assigns.current_user

    conn = put user_conn, user_path(user_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "update the user himself" do
    user = insert(:student)
    user_conn = login_as(:student)
    |> assign(:current_user, user)

    conn = put user_conn, user_path(user_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == summary_path(conn, :show)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "notify all users" do
    user_conn = login_as(:coordinator)

    conn = post user_conn, user_path(user_conn, :notify)
    assert redirected_to(conn) == user_path(conn, :index)
  end
end
