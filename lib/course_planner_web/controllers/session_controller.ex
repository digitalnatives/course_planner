defmodule CoursePlannerWeb.SessionController do
  use CoursePlannerWeb, :controller

  plug :put_layout, "session_layout.html"

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias CoursePlanner.Accounts.User

  def new(conn, _) do
    render conn, "new.html"
  end
  def create(conn, %{"session" => %{"email" => email,
                                    "password" => password}}) do
      # try to get user by unique email from DB
    trimmed_downcased_email =
      email
      |> String.trim()
      |> String.downcase()

    user = Repo.get_by(User, email: trimmed_downcased_email)
    # examine the result

    result = cond do
      # if user was found and provided password hash equals to stored
      # hash
      user && checkpw(password, user.password_hash) ->
        {:ok, login(conn, user)}
      # else if we just found the use
      user ->
        {:error, :unauthorized, conn}
      # otherwise
      true ->
        # simulate check password hash timing
        dummy_checkpw()
        {:error, :not_found, conn}
    end
    case result do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: "/dashboard")#dashboard_path(conn, :show))
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
    |> Guardian.Plug.sign_in(user)
  end

  defp logout(conn) do
    Guardian.Plug.sign_out(conn)
  end
end
