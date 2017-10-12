Code.ensure_loaded Phoenix.Swoosh

defmodule CoursePlannerWeb.Auth.UserEmail do
  @moduledoc false
  use Phoenix.Swoosh, view: CoursePlannerWeb.Auth.EmailView,
                      layout: {CoursePlannerWeb.Auth.LayoutView, :email}

  require Logger

  alias Swoosh.Email
  alias CoursePlanner.Mailer

  defp site_name, do: Application.get_env(:course_planner, :site_name)
  defp email_reply_to, do: Application.get_env(:course_planner, :auth_email_reply_to)
  defp email_from_name, do: Application.get_env(:course_planner, :auth_email_from_name)
  defp email_from_email, do: Application.get_env(:course_planner, :auth_email_from_email)

  def password(user, url) do
    create_modular_email(user, "#{site_name()} - Reset password instructions", "password.html",
                          %{url: url, name: first_name(user.name)})
  end

  def confirmation(user, url) do
    create_modular_email(user, "#{site_name()} - Confirm your new account", "confirmation.html",
                          %{url: url, name: first_name(user.name)})
  end

  def invitation(invitation, url) do
    create_modular_email(invitation, "#{site_name()} - Invitation to create a new account",
                         "invitation.html", %{url: url, name: first_name(invitation.name)})
  end

  def unlock(user, url) do
    create_modular_email(user, "#{site_name()} - Unlock Instructions", "unlock.html",
                          %{url: url, name: first_name(user.name)})
  end

  def welcome(user, url) do
    create_modular_email(
      user,
      "Welcome to #{site_name()}!",
      "welcome.html",
      %{url: url, name: first_name(user.name), role: user.role, site_name: site_name()})
  end

  defp create_modular_email(user, subject, render_body, render_body_params) do
    %Email{}
    |> from(from_email())
    |> to(user_email(user))
    |> add_reply_to()
    |> subject(subject)
    |> render_body(render_body, render_body_params)
  end

  defp add_reply_to(mail) do
    case email_reply_to() do
      nil              -> mail
      true             -> reply_to mail, from_email()
      address          -> reply_to mail, address
    end
  end

  defp first_name(nil), do: "there"
  defp first_name(name), do: name

  defp user_email(%{name: nil, email: email}), do: email
  defp user_email(%{name: name, email: email}), do: {name, email}

  defp from_email do
    log_string = ~s{Need to configure :auth_email, :email_from_name, "Name", \
and :email_from_email, "me@example.com"}

    name  = email_from_name()
    email = email_from_email()

    if is_nil(name) or is_nil(email) do
      Logger.error log_string
      nil
    else
      {name, email}
    end
  end

  def send_user_email(fun, model, url) do
    email = apply(__MODULE__, fun, [model, url])
    Logger.debug fn -> "#{fun} email: #{inspect email}" end
    Mailer.deliver(email)
  end
end
