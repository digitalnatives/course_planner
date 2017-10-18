defmodule CoursePlannerWeb.Auth.SessionController do
  @moduledoc """
    This module handles loging in to the system
  """
  use CoursePlannerWeb, :controller

  plug :put_layout, "session_layout.html"

  alias CoursePlanner.Accounts.{Users, User}
  alias Guardian.Plug

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email,
                                    "password" => password}}) do
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

        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")

      {:error, _reason} ->

        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> logout
    |> put_flash(:info, "See you later!")
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
