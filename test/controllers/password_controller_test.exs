defmodule CoursePlanner.PasswordControllerTest do
  use CoursePlannerWeb.ConnCase

  use ExUnit.Case, async: false

  import CoursePlanner.Factory
  import Swoosh.TestAssertions

  alias CoursePlanner.{Repo, Accounts.User}
  alias CoursePlannerWeb.{Auth.UserEmail, Router.Helpers}

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

  @moduletag user_role: nil
  describe "recaptcha config/login" do
    test "password reset creation fails if recaptcha verify fails", %{conn: conn} do
      Application.put_env(:recaptcha, :secret, "a_random_exiting_recaptcha")

      user = insert(:student,
        reset_password_token: nil,
        reset_password_sent_at: Timex.shift(Timex.now(), days: -10))
      params = %{"password" => %{"email" => user.email}, "g-recaptcha-response" => "invalid_response"}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 200) =~ "Send reset password link"
      assert html_response(conn, 200) =~ "Captcha is not validated"

      Application.put_env(:recaptcha, :secret, @google_recaptcha_test_secret)
    end

    test "password reset creation pass if recaptcha is not configured and not provided", %{conn: conn} do
      Application.put_env(:recaptcha, :secret, nil)

      user = insert(:student,
        reset_password_token: nil,
        reset_password_sent_at: Timex.shift(Timex.now(), days: -10))
      params = %{"password" => %{"email" => user.email}}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an email will be sent to it"

      updated_user = Repo.get_by(User, email: user.email)
      password_reset_url =  Helpers.password_url(conn, :edit, updated_user.reset_password_token)
      assert_email_sent UserEmail.password(user, password_reset_url)

      Application.put_env(:recaptcha, :secret, @google_recaptcha_test_secret)
    end

    test "password reset update fails if recaptcha recaptcha verify fails", %{conn: conn} do
      Application.put_env(:recaptcha, :secret, "a_random_exiting_recaptcha")

      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "new_password", "password_confirmation" => "new_password"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "Captcha is not validated"

      Application.put_env(:recaptcha, :secret, @google_recaptcha_test_secret)
    end

    test "password reset update pass if recaptcha is not configured and not provided", %{conn: conn} do
      Application.put_env(:recaptcha, :secret, nil)

      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "new_password", "password_confirmation" => "new_password"}}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "Password is successfully reset"

      Application.put_env(:recaptcha, :secret, @google_recaptcha_test_secret)
    end
  end

  describe "rendering of password reset page" do
    @tag user_role: nil
    test "password reset page is loaded for a not logged in request", %{conn: conn} do
      conn = get conn, password_path(conn, :new)
      assert html_response(conn, 200)
    end

    @tag user_role: :coordinator
    test "password reset page is loaded for a logged in request", %{conn: conn} do
      conn = get conn, password_path(conn, :new)
      assert html_response(conn, 200)
    end
  end

  @moduletag user_role: nil
  describe "creating password reset link" do
    test "password reset link won't be created if user does not exist", %{conn: conn} do
      params = %{"password" => %{"email" => "random@nonexisting.com"}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an email will be sent to it"
    end

    test "sending of the current token when it's still valid", %{conn: conn} do
      user = insert(:student,
        reset_password_token: "sample_reset_token",
        reset_password_sent_at: Timex.now())
      params = %{"password" => %{"email" => user.email}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an email will be sent to it"

      password_reset_url =  Helpers.password_url(conn, :edit, user.reset_password_token)
      assert_email_sent UserEmail.password(user, password_reset_url)
    end

    test "creation and sending of the password reset link", %{conn: conn} do
      user = insert(:student,
        reset_password_token: nil,
        reset_password_sent_at: Timex.shift(Timex.now(), days: -10))
      params = %{"password" => %{"email" => user.email}, "g-recaptcha-response" => "valid_response"}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an email will be sent to it"

      updated_user = Repo.get_by(User, email: user.email)
      password_reset_url =  Helpers.password_url(conn, :edit, updated_user.reset_password_token)
      assert_email_sent UserEmail.password(user, password_reset_url)
    end
  end

  @moduletag user_role: nil
  describe "rendering of password edit page" do
    test "successful if the reset token is valid and matches", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      conn = get conn, password_path(conn, :edit, user.reset_password_token)
      assert html_response(conn, 200) =~ "Create new password"
    end

    test "fails if token is expired", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -3)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      conn = get conn, password_path(conn, :edit, user.reset_password_token)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "error") == "Password token is expired. Contact your coordinator"
    end

    test "fails if token does not exist", %{conn: conn} do
      conn = get conn, password_path(conn, :edit, "a random non existing token")
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "error") == "Invalid reset token"
    end
  end

  @moduletag user_role: nil
  describe "resetting a user's password" do
    test "successful if the reset token is valid and matches", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "new_password", "password_confirmation" => "new_password"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "Password is successfully reset"
    end

    test "fails if token is expired", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -3)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "new_password", "password_confirmation" => "new_password"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "error") == "Password token is expired. Contact your coordinator"
    end

    test "does not update if confirmation does not match", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "new_password_1", "password_confirmation" => "new_password_2"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "does not match confirmation"
    end

    test "does not update if password is empty", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "", "password_confirmation" => "new_password_2"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "does not match confirmation"
    end

    test "does not update if password and it's confirmation are empty", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "", "password_confirmation" => ""}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "does not update if password length is less than 6 characters", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{"password" => %{"password" => "123", "password_confirmation" => "123"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, user.reset_password_token), params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "should be at least 8 character(s)"
    end

    test "fails if token does not exist", %{conn: conn} do
      params = %{"password" => %{"password" => "new_password", "password_confirmation" => "new_password"}, "g-recaptcha-response" => "valid_response"}
      conn = put conn, password_path(conn, :update, "random nonexisting token"), params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "error") == "Invalid reset token"
    end
  end
end
