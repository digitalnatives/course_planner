defmodule CoursePlanner.Mailer.UserEmail do
  @moduledoc """
  Module responsible for building and sending email
  """
  use Phoenix.Swoosh, view: CoursePlanner.EmailView, layout: {CoursePlanner.LayoutView, :email}

  @notifications %{
    user_modified: %{subject: "Your profile is updated", template: "user_updated.html"},
    course_updated: %{subject: "A course you subscribed to was updated", template: "course_updated.html"},
    course_deleted: %{subject: "A course you subscribed to was deleted", template: "course_deleted.html"},
    term_updated: %{subject: "A term you are enrolled in was updated", template: "term_updated.html"},
    term_deleted: %{subject: "A term you are enrolled in was deleted", template: "term_deleted.html"},
    class_subscribed: %{subject: "You were subscribed to a class", template: "class_subscribed.html"},
    class_updated: %{subject: "A class you subscribe to was updated", template: "class_updated.html"},
    class_deleted: %{subject: "A class you subscribe to was deleted", template: "class_deleted.html"},
  }

  def build_email(%{name: _, email: nil}, _, _), do: {:error, :invalid_recipient}
  def build_email(%{name: name, email: email}, notification_type, path) do
    case @notifications[notification_type] do
      nil -> {:error, :wrong_notification_type}
      params ->
        new()
        |> from("admin@courseplanner.com")
        |> to(email)
        |> subject(params.subject)
        |> render_body(params.template, %{name: name, path: path})
    end
  end
end
