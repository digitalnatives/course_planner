defmodule CoursePlannerWeb.Auth.PasswordController do
  @moduledoc """
    This module handle Reseting the password for user it is forgotten
  """
  use CoursePlannerWeb, :controller

  plug :put_layout, "session_layout.html"

  alias CoursePlanner.Accounts.User
  alias Timex.Comparable

  defp auth_password_reset_token_validation_days,
    do: Application.get_env(:course_planner, :auth_password_reset_token_validation_days)

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"password" => %{"email" => email}}) do
    trimmed_downcased_email =
      email
      |> String.trim()
      |> String.downcase()
    user = Repo.get_by(User, email: trimmed_downcased_email)

    if user do
      password_token_still_valid(user)
      # here we send the actual email to the user

      # if the token is valid send it
      # if not
      # creates a new reset token

      # creates the reset url
      # send the email
    end

    conn
    |> put_flash(:error, "If the email address is registered, an emaill will be send to it")
    |> redirect(to: session_path(conn, :new))
  end

  def edit(conn, %{"id" => token}) do
    user = Repo.get_by(User, reset_password_token: token)

    cond do
      is_nil(user) ->
        conn
        |> put_flash(:error, "Invalid reset token")
        |> redirect(to: session_path(conn, :new))

      not password_token_still_valid(user) ->
        conn
        |> put_flash(:error, "Password token is expired. Contact your coordinator")
        |> redirect(to: session_path(conn, :new))

      true ->
        changeset = User.changeset(user)
        render(conn, "edit.html", changeset: changeset, id: token)
    end
  end

  def update(conn, %{"password" => %{"password" => password,
                                     "password_confirmation" => password_confirmation,
                                     "reset_password_token" => reset_password_token}}) do

    user = Repo.get_by(User, reset_password_token: reset_password_token)

    cond do
      is_nil(user) ->
        conn
        |> put_flash(:error, "Invalid reset token")
        |> redirect(to: session_path(conn, :new))

      not password_token_still_valid(user) ->
        conn
        |> put_flash(:error, "Password token is expired. Contact your coordinator")
        |> redirect(to: session_path(conn, :new))

      true ->
        case set_new_password(user, password, password_confirmation)  do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "Password is successfully reset")
            |> redirect(to: session_path(conn, :new))

          {:error, changeset} ->
            conn
            |> render("edit.html", changeset: changeset, id: reset_password_token)
        end
    end
  end

  defp password_token_still_valid(user) do
    current_datetime = Timex.now()
    reset_password_sent_at = user.reset_password_sent_at

    days_since_reset_token_sent =
      Comparable.diff(current_datetime, reset_password_sent_at, :days)

    auth_password_reset_token_validation_days() >= days_since_reset_token_sent
  end

  defp set_new_password(user, password, password_confirmation) do
    update_params =
      %{
        reset_password_sent_at: nil,
        reset_password_token: nil,
        password: password,
        password_confirmation: password_confirmation
       }

    user
    |> User.changeset(update_params, :password_reset)
    |> Repo.update()
  end

  # defp updates_reset_token do
  #
  # end
end
