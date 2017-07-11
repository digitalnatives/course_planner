Code.ensure_loaded Phoenix.Swoosh

defmodule CoursePlanner.Coherence.UserEmail do
  @moduledoc false
  use Phoenix.Swoosh, view: Coherence.EmailView, layout: {Coherence.LayoutView, :email}
  alias Swoosh.Email
  require Logger
  alias Coherence.Config

  defp site_name, do: Config.site_name(inspect Config.module)

  def password(user, url) do
    create_modular_email(user, "#{site_name()} - Reset password instructions", "password.html",
                          %{url: url, name: first_name(user.name)})
  end

  def confirmation(user, url) do
    create_modular_email(user, "#{site_name()} - Confirm your new account", "confirmation.html",
                          %{url: url, name: first_name(user.name)})
  end

  def invitation(invitation, url) do
    create_modular_email(invitation, "#{site_name()} - Invitation to create a new account", "invitation.html",
                          %{url: url, name: first_name(invitation.name)})
  end

  def unlock(user, url) do
    create_modular_email(user, "#{site_name()} - Unlock Instructions", "unlock.html",
                          %{url: url, name: first_name(user.name)})
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
    case Config.email_reply_to do
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
    log_string = ~s{Need to configure :coherence, :email_from_name, "Name", \
and :email_from_email, "me@example.com"}

    case Config.email_from do
      nil ->
        Logger.error log_string
        nil
      {name, email} = email_tuple ->
        if is_nil(name) or is_nil(email) do
          Logger.error log_string
          nil
        else
          email_tuple
        end
    end
  end
end
