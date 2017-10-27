defmodule CoursePlannerWeb.Auth.SessionController do
  @moduledoc """
    This module handles loging in to the system
  """
  use CoursePlannerWeb, :controller

  plug :put_layout, "session_layout.html"

  alias CoursePlanner.Accounts.{Users, User}
  alias Recaptcha.Config
  alias Guardian.Plug

  def new(conn, _) do
    render(conn, "new.html", errors: [])
  end

  def create(conn, %{"session" => session, "g-recaptcha-response" => recaptcha_response}) do
    case Recaptcha.verify(recaptcha_response) do
      {:ok, _response} ->
        conn
        |> do_create(%{"session" => session})

      {:error, _errors} ->
        errors = [recaptcha: {"Captcha is not validated", []}]

        render(conn, "new.html", errors: errors)
    end
  end
  def create(conn, %{"session" => session}) do
    recaptcha_noconfigured? =
      is_nil(Config.get_env(:recaptcha, :secret))
        or is_nil(Config.get_env(:recaptcha, :public_key))

    if recaptcha_noconfigured? do
      do_create(conn, %{"session" => session})
    else
      errors = [recaptcha: {"Captcha is not validated", []}]

      render(conn, "new.html", errors: errors)
    end
  end

  defp do_create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    trimmed_downcased_email =
      email
      |> String.trim()
      |> String.downcase()
    user = Repo.get_by(User, email: trimmed_downcased_email)

    case Users.check_password(user, password) do
      {:ok, _reason} ->
        Users.update_login_fields(user, true)

        conn
        |> login(user)
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: dashboard_path(conn, :show))

      {:error, :unauthorized} ->
        Users.update_login_fields(user, false)

        errors = [email: {"Invalid email/password combination", []}]

        render(conn, "new.html", errors: errors)

      {:error, _reason} ->

        errors = [email: {"Invalid email/password combination", []}]

        render(conn, "new.html", errors: errors)
    end
  end

  def delete(conn, _) do
    conn
    |> logout
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: session_path(conn, :new))
  end

  defp login(conn, user) do
    conn
    |> Plug.sign_in(user)
  end

  defp logout(conn) do
    conn
    |> Plug.sign_out()
  end
end
