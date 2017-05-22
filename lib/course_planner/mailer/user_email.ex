defmodule CoursePlanner.Mailer.UserEmail do
  @moduledoc """
  Module responsible for building and sending email
  """
  use Phoenix.Swoosh, view: CoursePlanner.EmailView, layout: {CoursePlanner.LayoutView, :email}

  @notifications %{
    user_modified: %{subject: "Your profile was updated", template: "user_updated.html"},
    class_subscribed: %{subject: "You were subscribed to a class", template: "class_subscribed.html"},
    class_updated: %{subject: "A class you subscribe to was updated", template: "class_updated.html"},
  }

  def build_email(%{name: _, email: email}, _) when is_nil(email), do: {:error, :invalid_recipient}
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
