defmodule CoursePlanner.Mailer.UserEmail do
  @moduledoc """
  Module responsible for building and sending email
  """
  use Phoenix.Swoosh, view: CoursePlannerWeb.EmailView,
                      layout: {CoursePlannerWeb.LayoutView, :email}

  @notifications %{
    "user_modified" =>
      %{
        subject: "Your profile is updated",
        template: "user_updated.html"
      },
    "course_updated" =>
      %{
        subject: "A course you subscribed to was updated",
        template: "course_updated.html"
      },
    "course_deleted" =>
      %{
        subject: "A course you subscribed to was deleted",
        template: "course_deleted.html"
      },
    "term_updated" =>
      %{
        subject: "A term you are enrolled in was updated",
        template: "term_updated.html"
      },
    "term_deleted" =>
      %{
        subject: "A term you are enrolled in was deleted",
        template: "term_deleted.html"
        },
    "class_subscribed" =>
      %{
        subject: "You were subscribed to a class",
        template: "class_subscribed.html"
      },
    "class_updated" =>
      %{
        subject: "A class you subscribe to was updated",
        template: "class_updated.html"
      },
    "class_deleted" =>
      %{
        subject: "A class you subscribe to was deleted",
        template: "class_deleted.html"
      },
    "attendance_missing" =>
      %{
        subject: "One or more attendances are not filled",
        template: "attendance_missing.html"
      },
    "event_created" =>
      %{
        subject: "You were invited to an event",
        template: "event_created.html"
      },
    "event_uninvited" =>
      %{
        subject: "You were uninvited from an event",
        template: "event_uninvited.html"
      },
    "event_updated" =>
      %{
        subject: "An event you were invited to was updated",
        template: "event_updated.html"
      },
  }

  def build_email(%{user: %{name: _, email: nil}}), do: {:error, :invalid_recipient}
  def build_email(%{user: %{name: name, email: email},
                  type: type, resource_path: path, data: data}) do
    case @notifications[type] do
      nil -> {:error, :wrong_notification_type}
      params ->
        new()
        |> from("admin@courseplanner.com")
        |> to(email)
        |> subject(params.subject)
        |> render_body(params.template, %{name: name, path: path, data: data})
    end
  end

  def build_summary(%{notifications: []}), do: {:error, :empty_notifications}
  def build_summary(%{name: name, email: email, notifications: notifications}) do
    new()
    |> from("admin@courseplanner.com")
    |> to(email)
    |> subject("Activity Summary")
    |> render_body("summary.html",
      %{name: name, notifications: notifications, params: @notifications})
  end

end
