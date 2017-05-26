defmodule CoursePlanner.Mailer.UserEmail do
  @moduledoc """
  Module responsible for building and sending email
  """
  use Phoenix.Swoosh, view: CoursePlanner.EmailView, layout: {CoursePlanner.LayoutView, :email}

  @notifications %{
    user_modified: %{subject: "Your profile is updated", template: "user_updated.html"}
  }

  def build_email(%{name: _, email: nil}, _), do: {:error, :invalid_recipient}
  def build_email(%{name: name, email: email}, notification_type) do
    case @notifications[notification_type] do
      nil -> {:error, :wrong_notification_type}
      params ->
        new()
        |> from("admin@courseplanner.com")
        |> to(email)
        |> subject(params.subject)
        |> render_body(params.template, %{name: name})
    end
  end
end
