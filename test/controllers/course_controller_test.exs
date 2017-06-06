defmodule CoursePlanner.CourseControllerTest do
  use CoursePlanner.ConnCase
  alias CoursePlanner.User
  alias CoursePlanner.Course

  import CoursePlanner.Factory

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

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
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
    conn = get conn, course_path(conn, :show, -1)
    assert html_response(conn, 404)
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

  test "deletes chosen resource when the states is Planned", %{conn: conn} do
    course = Repo.insert! %Course{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %Ecto.Time{hour: 2, min: 0, sec: 0}, status: "Planned", syllabus: "some content"}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    refute Repo.get(Course, course.id)
  end

  test "deletes chosen resource when the states is Active", %{conn: conn} do
    course = Repo.insert! %Course{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %Ecto.Time{hour: 2, min: 0, sec: 0}, status: "Active", syllabus: "some content"}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    soft_deleted_course = Repo.get(Course, course.id)
    assert soft_deleted_course.deleted_at
  end

  test "deletes chosen resource when the states is Finished", %{conn: conn} do
    course = Repo.insert! %Course{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %Ecto.Time{hour: 2, min: 0, sec: 0}, status: "Finished", syllabus: "some content"}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    soft_deleted_course = Repo.get(Course, course.id)
    assert soft_deleted_course.deleted_at
  end

  test "deletes chosen resource when the states is Graduated", %{conn: conn} do
    course = Repo.insert! %Course{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %Ecto.Time{hour: 2, min: 0, sec: 0}, status: "Graduated", syllabus: "some content"}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    soft_deleted_course = Repo.get(Course, course.id)
    assert soft_deleted_course.deleted_at
  end

  test "deletes chosen resource when the states is Frozen", %{conn: conn} do
    course = Repo.insert! %Course{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %Ecto.Time{hour: 2, min: 0, sec: 0}, status: "Frozen", syllabus: "some content"}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    soft_deleted_course = Repo.get(Course, course.id)
    assert soft_deleted_course.deleted_at
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

  test "does not create resource and renders errors when data value of status is Finished", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | status: "Finished"}
    assert html_response(conn, 200) =~ "New course"
  end

  test "does not create resource and renders errors when data value of status is Graduated", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | status: "Graduated"}
    assert html_response(conn, 200) =~ "New course"
  end

  test "does not create resource and renders errors when data value of status is Frozen", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: %{@valid_attrs | status: "Frozen"}
    assert html_response(conn, 200) =~ "New course"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    course = insert(:course)

    conn = get student_conn, course_path(student_conn, :show, course)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :show, course)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :show, course)
    assert html_response(conn, 403)
  end


  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, course_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    course = insert(:course)

    conn = get student_conn, course_path(student_conn, :edit, course)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :edit, course)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :edit, course)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    course = insert(:course)

    conn = delete student_conn, course_path(student_conn, :delete, course.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, course_path(teacher_conn, :delete, course.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, course_path(volunteer_conn, :delete, course.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new class for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, course_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create class for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    course = insert(:course)

    conn = post student_conn, course_path(student_conn, :create), class: course
    assert html_response(conn, 403)

    conn = post teacher_conn, course_path(teacher_conn, :create), class: course
    assert html_response(conn, 403)

    conn = post volunteer_conn, course_path(volunteer_conn, :create), class: course
    assert html_response(conn, 403)
  end

  test "does not update chosen course for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    course = Repo.insert! %Course{}

    conn = put student_conn, course_path(student_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)

    conn = put teacher_conn, course_path(teacher_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)

    conn = put volunteer_conn, course_path(volunteer_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)
  end
end
