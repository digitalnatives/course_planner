defmodule CoursePlanner.TeacherControllerTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlanner.{Repo, Accounts.User}
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
    conn = get conn, teacher_path(conn, :index)
    assert html_response(conn, 200) =~ "Teachers"
  end

  test "does not teacher student for coordinator user when data is invalid", %{conn: conn} do
    conn = post conn, teacher_path(conn, :create), %{"user" => %{"email" => ""}}
    assert html_response(conn, 200) =~ "Something went wrong."
  end

  test "create teacher for coordinator user", %{conn: conn} do
    conn = post conn, teacher_path(conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == teacher_path(conn, :index)
    conn = get conn, teacher_path(conn, :index)
    assert html_response(conn, 200)
  end

  test "shows chosen resource", %{conn: conn} do
    teacher = insert(:teacher)
    conn = get conn, teacher_path(conn, :show, teacher)
    assert html_response(conn, 200) =~ "#{teacher.name} #{teacher.family_name}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, teacher_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    teacher = insert(:teacher, %{name: "Foo", family_name: "Bar"})
    conn = get conn, teacher_path(conn, :edit, teacher)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    teacher = insert(:teacher, %{})
    conn = put conn, teacher_path(conn, :update, teacher), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == teacher_path(conn, :show, teacher)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "does not updates if the resource does not exist", %{conn: conn} do
    conn = put conn, teacher_path(conn, :update, -1), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 404)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    teacher = insert(:teacher, %{name: "Foo", family_name: "Bar"})
    conn = put conn, teacher_path(conn, :update, teacher), %{"user" => %{"email" => "not email"}}
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "deletes chosen resource", %{conn: conn} do
    teacher = insert(:teacher)
    conn = delete conn, teacher_path(conn, :delete, teacher)
    assert redirected_to(conn) == teacher_path(conn, :index)
    refute Repo.get(User, teacher.id)
  end

  test "does not delete chosen resource when does not exist", %{conn: conn} do
    conn = delete conn, teacher_path(conn, :delete, "-1")
    assert redirected_to(conn) == teacher_path(conn, :index)
    conn = get conn, teacher_path(conn, :index)
    assert html_response(conn, 200) =~ "Teacher was not found."
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, teacher_path(conn, :new)
    assert html_response(conn, 200) =~ "New teacher"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    teacher = insert(:teacher)

    conn = get student_conn, teacher_path(student_conn, :show, teacher)
    assert html_response(conn, 403)

    conn = get teacher_conn, teacher_path(teacher_conn, :show, teacher)
    assert html_response(conn, 403)

    conn = get volunteer_conn, teacher_path(volunteer_conn, :show, teacher)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, teacher_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, teacher_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, teacher_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    teacher = insert(:teacher)

    conn = get student_conn, teacher_path(student_conn, :edit, teacher)
    assert html_response(conn, 403)

    conn = get teacher_conn, teacher_path(teacher_conn, :edit, teacher)
    assert html_response(conn, 403)

    conn = get volunteer_conn, teacher_path(volunteer_conn, :edit, teacher)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    teacher = insert(:teacher)

    conn = delete student_conn, teacher_path(student_conn, :delete, teacher.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, teacher_path(teacher_conn, :delete, teacher.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, teacher_path(volunteer_conn, :delete, teacher.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new teacher for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, teacher_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, teacher_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, teacher_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create teacher for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = post student_conn, teacher_path(student_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = post teacher_conn, teacher_path(teacher_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = post volunteer_conn, teacher_path(volunteer_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end

  test "does not update chosen teacher for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    teacher = insert(:teacher, %{})

    conn = put student_conn, teacher_path(student_conn, :update, teacher), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, teacher_path(teacher_conn, :update, teacher), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, teacher_path(volunteer_conn, :update, teacher), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end

  test "show the teacher himself" do
    teacher = insert(:teacher)
    teacher_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, teacher)

    conn = get teacher_conn, teacher_path(teacher_conn, :show, teacher)
    assert html_response(conn, 200) =~ "#{teacher.name} #{teacher.family_name}"
  end

  test "edit the teacher himself" do
    teacher = insert(:teacher, name: "Foo", family_name: "Bar")
    teacher_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, teacher)

    conn = get teacher_conn, teacher_path(teacher_conn, :edit, teacher)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "update the teacher himself" do
    teacher = insert(:teacher)
    teacher_conn = Phoenix.ConnTest.build_conn()
    |> assign(:current_user, teacher)

    conn = put teacher_conn, teacher_path(teacher_conn, :update, teacher), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == teacher_path(conn, :show, teacher)
    assert Repo.get_by(User, email: "foo@bar.com")
  end
end
