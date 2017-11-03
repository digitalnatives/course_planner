defmodule CoursePlanner.UserControllerTest do
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
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "All users"
  end

  test "lists all entries on index for supervisor" do
    conn = login_as(:supervisor)
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "All users"
  end

  test "shows chosen resource", %{conn: conn} do
    user = insert(:student)
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~
      Enum.join([user.name, user.family_name], " ")
  end

  test "shows chosen resource for supervisor" do
    conn = login_as(:supervisor)
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
    supervisor_conn = login_as(:supervisor)

    user = insert(:student)

    conn = get student_conn, user_path(student_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get teacher_conn, user_path(teacher_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get volunteer_conn, user_path(volunteer_conn, :edit, user)
    assert html_response(conn, 403)

    conn = get supervisor_conn, user_path(supervisor_conn, :edit, user)
    assert html_response(conn, 403)
  end

  test "coordinator delete a user successfully", %{conn: conn} do
    user = insert(:student)

    conn = delete conn, user_path(conn, :delete, user.id)
    assert redirected_to(conn) == user_path(conn, :index)
    assert get_flash(conn, "info") == "User deleted successfully."
  end

  test "does not delete a non-existing user", %{conn: conn} do
    conn = delete conn, user_path(conn, :delete, -1)
    assert redirected_to(conn) == user_path(conn, :index)
    assert get_flash(conn, "error") == "User was not found."
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    user = insert(:student)

    conn = delete student_conn, user_path(student_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, user_path(teacher_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, user_path(volunteer_conn, :delete, user.id)
    assert html_response(conn, 403)

    conn = delete supervisor_conn, user_path(supervisor_conn, :delete, user.id)
    assert html_response(conn, 403)
  end

  test "does not update chosen user for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    user = insert(:student, %{})

    conn = put student_conn, user_path(student_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, user_path(teacher_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, user_path(volunteer_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put supervisor_conn, user_path(supervisor_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
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
    user_conn = guardian_login_html(user)

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
    user_conn = guardian_login_html(user)

    conn = put user_conn, user_path(user_conn, :update, user), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == dashboard_path(conn, :show)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "notify all users" do
    user_conn = login_as(:coordinator)

    conn = post user_conn, user_path(user_conn, :notify)
    assert redirected_to(conn) == user_path(conn, :index)
  end

  test "resend notification to user if password reset token is valid" do
    user_conn = login_as(:coordinator)
    user = insert(:user, %{reset_password_token: "whatever"})

    conn = put user_conn, user_path(user_conn, :resend_email, user.id)
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert get_flash(conn, "info") == "Reset e-mail sent."
  end

  test "resend notification to user if password reset token is not valid" do
    user_conn = login_as(:coordinator)
    user = insert(:user, %{reset_password_token: nil})

    conn = put user_conn, user_path(user_conn, :resend_email, user.id)
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert get_flash(conn, "info") == "User has already set her password in the system."
  end

  test "don't resend notification to inexistent user" do
    user_conn = login_as(:coordinator)

    conn = put user_conn, user_path(user_conn, :resend_email, -1)
    assert html_response(conn, 404)
  end
end
