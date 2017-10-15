defmodule CoursePlanner.SessionControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup(param) do
    conn =
      case param do
        %{user_role: nil} -> Phoenix.ConnTest.build_conn()
        %{user_role: role} -> login_as(role)
      end

    {:ok, conn: conn}
  end

  defp login_as(role) do
    role
    |> insert()
    |> guardian_login_html()
  end


  describe "before being logged in" do
    @tag user_role: nil
    test "rendering of the login the page", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200)
    end

    @tag user_role: :nil
    test "rendering of the root page redirects to the login the page", %{conn: conn} do
      conn = get conn, dashboard_path(conn, :show)
      assert html_response(conn, 302) =~ "/sessions/new"
    end

    @tag user_role: :nil
    test "rendering of the random page redirects to the login the page", %{conn: conn} do
      conn = get conn, about_path(conn, :show)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, attendance_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, bulk_path(conn, :new)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, class_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, course_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, term_course_matrix_path(conn, :index, 1)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, offered_course_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, schedule_path(conn, :show)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, student_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, task_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, teacher_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, term_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

      conn = get conn, volunteer_path(conn, :index)
      assert html_response(conn, 302) =~ "/sessions/new"

    end
  end

  describe "loggin functionality" do
    @tag user_role: nil
    test "successful login", %{conn: conn} do
      user = insert(:coordinator)
      login_params = %{session: %{email: user.email, password: "secret"}}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 302)

      conn = get conn, dashboard_path(conn, :show)
      assert html_response(conn, 200)
      assert get_flash(conn, "info") == "You’re now logged in!"
    end

    @tag user_role: nil
    test "unsuccessful login due to a non-existing user", %{conn: conn} do
      login_params = %{session: %{email: "non-existint-user@email.com", password: "random password"}}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "Invalid email/password combination"
    end

    @tag user_role: nil
    test "unsuccessful login due to a wrong password", %{conn: conn} do
      user = insert(:coordinator)
      login_params = %{session: %{email: user.email, password: "wrong password"}}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "Invalid email/password combination"
    end
  end

  @moduletag user_role: :coordinator
  describe "logout functionality" do
     test "successfully loging out an already loged in user", %{conn: conn} do
       user = conn.assigns.current_user
       conn = delete conn, session_path(conn, :delete, user)
       assert html_response(conn, 302)
       assert redirected_to(conn) == session_path(conn, :new)

       conn = get conn, dashboard_path(conn, :show)
       assert html_response(conn, 302)
       assert redirected_to(conn) == session_path(conn, :new)
     end

    test "nothing happenps when loging out request comes from a not loged in user", %{conn: conn} do
      conn = delete conn, session_path(conn, :delete, 1234)
      assert html_response(conn, 302)
      assert redirected_to(conn) == session_path(conn, :new)
    end
  end
end
