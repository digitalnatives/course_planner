defmodule CoursePlannerWeb.Auth.SessionController do
  @moduledoc """
    This module handles loging in to the system
  """
  use CoursePlannerWeb, :controller

  plug :put_layout, "session_layout.html"

  alias CoursePlanner.Accounts.User
  alias Comeonin.Bcrypt
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

    result = cond do

      user && Bcrypt.checkpw(password, user.password_hash) -> {:ok, login(conn, user)}

      user -> {:error, :unauthorized, conn}

      true -> Bcrypt.dummy_checkpw()
        {:error, :not_found, conn}
    end

    case result do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: dashboard_path(conn, :show))

      {:error, _reason, conn} ->
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
