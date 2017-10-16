defmodule CoursePlanner.PasswordControllerTest do
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
      params = %{password: %{email: "random@nonexisting.com"}}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an emaill will be send to it"
    end

    test "sending of the current token if it is still valid", %{conn: conn} do
      user = insert(:student, reset_password_token: nil)
      params = %{password: %{email: user.email}}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an emaill will be send to it"
    end

    test "creation and sending of the password reset link", %{conn: conn} do
      user = insert(:student)
      params = %{password: %{email: user.email}}
      conn = post conn, password_path(conn, :create, params)
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "If the email address is registered, an emaill will be send to it"
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
      params = %{password: "new_password", password_confirmation: "new_password", reset_password_token: user.reset_password_token}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "info") == "Password is successfully reset"
    end

    test "fails if token is expired", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -3)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{password: "new_password", password_confirmation: "new_password", reset_password_token: user.reset_password_token}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "error") == "Password token is expired. Contact your coordinator"
    end

    test "does not update if confirmation does not match", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{password: "new_password_1", password_confirmation: "new_password_2", reset_password_token: user.reset_password_token}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "does not match confirmation"
    end

    test "does not update if password is empty", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{password: "", password_confirmation: "new_password_2", reset_password_token: user.reset_password_token}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "does not match confirmation"
    end

    test "does not update if password and it's confirmation are empty", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{password: "", password_confirmation: "", reset_password_token: user.reset_password_token}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "does not update if password length is less than 6 characters", %{conn: conn} do
      reset_password_sent_at = Timex.shift(Timex.now(), days: -1)
      user = insert(:student, reset_password_token: "my_token", reset_password_sent_at: reset_password_sent_at)
      params = %{password: "123", password_confirmation: "123", reset_password_token: user.reset_password_token}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 200) =~ "Create new password"
      assert html_response(conn, 200) =~ "should be at least 6 character(s)"
    end

    test "fails if token does not exist", %{conn: conn} do
      params = %{password: "new_password", password_confirmation: "new_password", reset_password_token: "random non existing token"}
      conn = put conn, password_path(conn, :update, 0), password: params
      assert html_response(conn, 302) =~ "/sessions/new"
      assert get_flash(conn, "error") == "Invalid reset token"
    end
  end
end
