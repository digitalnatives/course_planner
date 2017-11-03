defmodule CoursePlanner.StudentControllerTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlanner.{Repo, Accounts.User}
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
    conn = get conn, student_path(conn, :index)
    assert html_response(conn, 200) =~ "Students"
  end

  test "lists all entries on index for supervisor" do
    conn = login_as(:supervisor)
    conn = get conn, student_path(conn, :index)
    assert html_response(conn, 200) =~ "Students"
  end

  test "does not create student for coordinator user when data is invalid", %{conn: conn} do
    conn = post conn, student_path(conn, :create), %{"user" => %{"email" => ""}}
    assert html_response(conn, 200) =~ "Something went wrong."
  end

  test "create student for coordinator user", %{conn: conn} do
    conn = post conn, student_path(conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == student_path(conn, :index)
    assert get_flash(conn, "info") == "Student created and notified by."
  end

  test "does not create student for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    student = insert(:student)

    conn = post student_conn, student_path(student_conn, :create), %{"user" => student}
    assert html_response(conn, 403)

    conn = post teacher_conn, student_path(teacher_conn, :create), %{"user" => student}
    assert html_response(conn, 403)

    conn = post volunteer_conn, student_path(volunteer_conn, :create), %{"user" => student}
    assert html_response(conn, 403)

    conn = post supervisor_conn, student_path(supervisor_conn, :create), %{"user" => student}
    assert html_response(conn, 403)
  end

  test "shows chosen resource", %{conn: conn} do
    student = insert(:student)
    conn = get conn, student_path(conn, :show, student)
    assert html_response(conn, 200) =~ "#{student.name} #{student.family_name}"
  end

  test "shows chosen resource for supervisor" do
    conn = login_as(:supervisor)
    student = insert(:student)
    conn = get conn, student_path(conn, :show, student)
    assert html_response(conn, 200) =~ "#{student.name} #{student.family_name}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, student_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    student = insert(:student, %{name: "Foo", family_name: "Bar"})
    conn = get conn, student_path(conn, :edit, student)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    student = insert(:student, %{})
    conn = put conn, student_path(conn, :update, student), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == student_path(conn, :show, student)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "does not updates if the resource does not exist", %{conn: conn} do
    conn = put conn, student_path(conn, :update, -1), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 404)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    student = insert(:student, %{name: "Foo", family_name: "Bar"})
    conn = put conn, student_path(conn, :update, student), %{"user" => %{"email" => "not email"}}
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "deletes chosen resource", %{conn: conn} do
    student = insert(:student)
    conn = delete conn, student_path(conn, :delete, student)
    assert redirected_to(conn) == student_path(conn, :index)
    refute Repo.get(User, student.id)
  end

  test "does not delete chosen resource when does not exist", %{conn: conn} do
    conn = delete conn, student_path(conn, :delete, "-1")
    assert redirected_to(conn) == student_path(conn, :index)
    assert get_flash(conn, "error") == "Student was not found."
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, student_path(conn, :new)
    assert html_response(conn, 200) =~ "New student"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    student = insert(:student)

    conn = get student_conn, student_path(student_conn, :show, student)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :show, student)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :show, student)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, student_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    student = insert(:student)

    conn = get student_conn, student_path(student_conn, :edit, student)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :edit, student)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :edit, student)
    assert html_response(conn, 403)

    conn = get supervisor_conn, student_path(supervisor_conn, :edit, student)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    student = insert(:student)

    conn = delete student_conn, student_path(student_conn, :delete, student.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, student_path(teacher_conn, :delete, student.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, student_path(volunteer_conn, :delete, student.id)
    assert html_response(conn, 403)

    conn = delete supervisor_conn, student_path(supervisor_conn, :delete, student.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new class for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    conn = get student_conn, student_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, student_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, student_path(volunteer_conn, :new)
    assert html_response(conn, 403)

    conn = get supervisor_conn, student_path(supervisor_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not update chosen student for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    student = insert(:student, %{})

    conn = put student_conn, student_path(student_conn, :update, student), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, student_path(teacher_conn, :update, student), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, student_path(volunteer_conn, :update, student), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put supervisor_conn, student_path(supervisor_conn, :update, student), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end

  test "show the student himself" do
    student = insert(:student)
    student_conn = guardian_login_html(student)

    conn = get student_conn, student_path(student_conn, :show, student)
    assert html_response(conn, 200) =~ "#{student.name} #{student.family_name}"
  end

  test "edit the student himself" do
    student = insert(:student, %{name: "Foo", family_name: "Bar"})
    student_conn = guardian_login_html(student)

    conn = get student_conn, student_path(student_conn, :edit, student)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "update the student himself" do
    student = insert(:student)
    student_conn = guardian_login_html(student)

    conn = put student_conn, student_path(student_conn, :update, student), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == student_path(conn, :show, student)
    assert Repo.get_by(User, email: "foo@bar.com")
  end
end
