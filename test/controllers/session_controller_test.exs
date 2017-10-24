defmodule CoursePlanner.SessionControllerTest do
  use CoursePlannerWeb.ConnCase
  use ExUnit.Case, async: false

  import CoursePlanner.Factory

  alias CoursePlanner.{Repo, Accounts.User}

  @google_recaptcha_test_secret "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

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

  describe "recaptcha config/login" do
    @tag user_role: nil
    test "login is unsuccessful if recaptcha verify fails", %{conn: conn} do
      Application.put_env(:recaptcha, :secret, "a_random_exiting_recaptcha")

      user = insert(:coordinator)
      login_params = %{"session" => %{"email" => user.email, "password" => "secret"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 200) =~ "Captcha is not validated"

      Application.put_env(:recaptcha, :secret, @google_recaptcha_test_secret)
    end

    @tag user_role: nil
    test "login is successful if recaptcha is not configured", %{conn: conn} do
      Application.put_env(:recaptcha, :secret, nil)

      user = insert(:coordinator)
      login_params = %{"session" => %{"email" => user.email, "password" => "secret"}}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 302)

      conn = get conn, dashboard_path(conn, :show)
      assert html_response(conn, 200)
      assert get_flash(conn, "info") == "You’re now logged in!"

      Application.put_env(:recaptcha, :secret, @google_recaptcha_test_secret)
    end
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
      login_params = %{"session" => %{"email" => user.email, "password" => "secret"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 302)

      conn = get conn, dashboard_path(conn, :show)
      assert html_response(conn, 200)
      assert get_flash(conn, "info") == "You’re now logged in!"
    end

    @tag user_role: nil
    test "login fails when captcha is not provided but is confugured in the config", %{conn: conn} do
      user = insert(:coordinator)
      login_params = %{"session" => %{"email" => user.email, "password" => "secret"}}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 200) =~ "Captcha is not validated"
    end

    @tag user_role: nil
    test "update of the login fields", %{conn: conn} do
      user = insert(:coordinator, last_sign_in_at: Timex.shift(Timex.now(), days: -2))
      login_params = %{"session" => %{"email" => user.email, "password" => "random"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, session_path(conn, :create, login_params)
      conn = post conn, session_path(conn, :create, login_params)

      user = Repo.get_by(User, email: user.email)
      assert user.failed_attempts == 2

      login_params = %{"session" => %{"email" => user.email, "password" => "secret"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, session_path(conn, :create, login_params)

      conn = get conn, dashboard_path(conn, :show)
      assert html_response(conn, 200)
      assert get_flash(conn, "info") == "You’re now logged in!"

      user = Repo.get_by(User, email: user.email)
      assert user.failed_attempts == 0
      assert Timex.Comparable.diff(Timex.now(), user.last_sign_in_at, :days) == 0
    end

    @tag user_role: nil
    test "unsuccessful login due to a non-existing user", %{conn: conn} do
      login_params = %{"session" => %{"email" => "non-existint-user@email.com", "password" => "random password"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 200) =~ "Invalid email/password combination"
    end

    @tag user_role: nil
    test "unsuccessful login due to a wrong password", %{conn: conn} do
      user = insert(:coordinator)
      login_params = %{"session" => %{"email" => user.email, "password" => "wrong password"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, session_path(conn, :create, login_params)
      assert html_response(conn, 200) =~ "Invalid email/password combination"
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


    test "a logged-in user cannot be logged out by a non logged-in request", %{conn: conn} do
      current_logged_in_user = conn.assigns.current_user

      unauthenticated_conn = Phoenix.ConnTest.build_conn
      unauthenticated_conn = delete unauthenticated_conn, session_path(unauthenticated_conn, :delete, current_logged_in_user)
      assert html_response(unauthenticated_conn, 302)
      assert redirected_to(unauthenticated_conn) == session_path(unauthenticated_conn, :new)

      conn = get conn, dashboard_path(conn, :show)
      assert html_response(conn, 200)
    end
  end
end
