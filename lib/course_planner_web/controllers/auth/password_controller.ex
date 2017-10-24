defmodule CoursePlannerWeb.Auth.PasswordController do
  @moduledoc """
    This module handle Reseting the password for user it is forgotten
  """
  use CoursePlannerWeb, :controller

  plug :put_layout, "session_layout.html"

  alias CoursePlanner.Accounts.{Users, User}
  alias CoursePlannerWeb.{Auth.UserEmail, Router.Helpers}
  alias Recaptcha.Config

  def new(conn, _) do
    render(conn, "new.html", errors: [])
  end

  def create(conn, %{"password" => create_params, "g-recaptcha-response" => recaptcha_response}) do
    case Recaptcha.verify(recaptcha_response) do
      {:ok, _response} ->
        conn
        |> do_create(%{"password" => create_params})

      {:error, _errors} ->
        errors = [recaptcha: {"Captcha is not validated", []}]

        conn
        |> render("new.html", errors: errors)
    end
  end
  def create(conn, %{"password" => %{"email" => _email}} = params) do
    recaptcha_noconfigured? =
      is_nil(Config.get_env(:recaptcha, :secret))
        or is_nil(Config.get_env(:recaptcha, :public_key))

    if recaptcha_noconfigured? do
      do_create(conn, params)
    else
      errors = [recaptcha: {"Captcha is not validated", []}]

      conn
      |> render("new.html", errors: errors)
    end
  end
  def do_create(conn, %{"password" => %{"email" => email}}) do
    trimmed_downcased_email =
      email
      |> String.trim()
      |> String.downcase()
    user = Repo.get_by(User, email: trimmed_downcased_email)

    if user do
      updated_user = set_new_password_reset_token(user)
      password_reset_url =  Helpers.password_url(conn, :edit, updated_user.reset_password_token)
      UserEmail.send_user_email(:password, updated_user, password_reset_url)
    end

    conn
    |> put_flash(:info, "If the email address is registered, an email will be sent to it")
    |> redirect(to: session_path(conn, :new))
  end

  def edit(conn, %{"id" => reset_password_token}) do
    case check_password_reset_token(reset_password_token) do
      {:ok, _reason, _user} ->
        render(conn, "edit.html", id: reset_password_token, errors: [])

      {:error, :expired_token, _user} ->
        conn
        |> put_flash(:error, "Password token is expired. Contact your coordinator")
        |> redirect(to: session_path(conn, :new))

      {:error, :invalid_token, _user} ->
        conn
        |> put_flash(:error, "Invalid reset token")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def update(conn, %{"id" => reset_password_token,
                     "password" => %{"password" => password,
                                     "password_confirmation" => password_confirmation},
                     "g-recaptcha-response" => recaptcha_response}) do

    update_params = %{"id" => reset_password_token,
                      "password" => %{"password" => password,
                                      "password_confirmation" => password_confirmation}}
    case Recaptcha.verify(recaptcha_response) do
      {:ok, _response} ->
        conn
        |> do_update(update_params)

      {:error, _errors} ->
        errors = [recaptcha: {"Captcha is not validated", []}]

        conn
        |> render("edit.html", id: reset_password_token, errors: errors)
    end
  end
  def update(conn, %{"id" => reset_password_token} = params) do
    recaptcha_noconfigured? =
      is_nil(Config.get_env(:recaptcha, :secret))
        or is_nil(Config.get_env(:recaptcha, :public_key))

    if recaptcha_noconfigured? do
      do_update(conn, params)
    else
      errors = [recaptcha: {"Captcha is not validated", []}]

      conn
      |> render("edit.html", id: reset_password_token,
                errors: errors)
    end
  end
  def do_update(conn, %{"id" => reset_password_token,
                        "password" => %{"password" => password,
                                        "password_confirmation" => password_confirmation}}) do
     case check_password_reset_token(reset_password_token) do
       {:ok, _reason, user} ->
         case set_new_password(user, password, password_confirmation)  do
           {:ok, _user} ->
             conn
             |> put_flash(:info, "Password is successfully reset")
             |> redirect(to: session_path(conn, :new))

           {:error, changeset} ->
             conn
             |> render("edit.html", id: reset_password_token, errors: changeset.errors)
         end

       {:error, :expired_token, _user} ->
         conn
         |> put_flash(:error, "Password token is expired. Contact your coordinator")
         |> redirect(to: session_path(conn, :new))

       {:error, :invalid_token, _user} ->
         conn
         |> put_flash(:error, "Invalid reset token")
         |> redirect(to: session_path(conn, :new))
     end
  end

  defp check_password_reset_token(reset_password_token) do
    user = Repo.get_by(User, reset_password_token: reset_password_token)

    cond do
      is_nil(user) -> {:error, :invalid_token, nil}

      not Users.reset_password_token_valid?(user) -> {:error, :expired_token, nil}

      true -> {:ok, :valid_token, user}
    end
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

  defp set_new_password_reset_token(user) do
    update_params = Users.get_new_password_reset_token(user)

    user
    |> User.changeset(update_params)
    |> Repo.update!()
  end
end
