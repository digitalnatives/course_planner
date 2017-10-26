defmodule CoursePlanner.UserEmailTest do
  use CoursePlannerWeb.ModelCase
  doctest CoursePlanner.Mailer.UserEmail

  alias CoursePlanner.{Accounts.User, Notifications.Notification, Notifications,
                       Mailer, Mailer.UserEmail, Attendances}
  import Swoosh.TestAssertions

  import CoursePlanner.Factory

  @valid_user %User{name: "mahname", email: "valid@email"}
  @invalid_user %User{name: "mahname"}
  @invalid_user2 %User{name: "mahname", email: nil}

  test "inexistent notification type" do
    assert UserEmail.build_email(%Notification{user: @valid_user, type: :sometype}) == {:error, :wrong_notification_type}
  end

  test "empty e-mail" do
    assert UserEmail.build_email(%Notification{user: @invalid_user, type: :user_modified}) == {:error, :invalid_recipient}
  end

  test "nil e-mail" do
    assert UserEmail.build_email(%Notification{user: @invalid_user2, type: :user_modified}) == {:error, :invalid_recipient}
  end

  for email <- [
    {:user_modified, "Your profile is updated"},
    {:course_updated, "A course you subscribed to was updated"},
    {:course_deleted, "A course you subscribed to was deleted"},
    {:term_updated, "A term you are enrolled in was updated"},
    {:term_deleted, "A term you are enrolled in was deleted"},
    {:class_subscribed, "You were subscribed to a class"},
    {:class_updated, "A class you subscribe to was updated"},
    {:class_deleted, "A class you subscribe to was deleted"},
    {:event_created, "You were invited to an event"},
    {:event_uninvited, "You were uninvited from an event"},
    {:event_updated, "An event you were invited to was updated"}
    ] do
    @email email
    test "notify #{inspect @email}" do
      {type, subject} = @email
      Notifications.new()
      |> Notifications.to(@valid_user)
      |> Notifications.type(type)
      |> UserEmail.build_email()
      |> Mailer.deliver()
      assert_email_sent subject: subject
    end
  end

  test "missing attendance email" do
    teacher = insert(:teacher)
    offered_course = insert(:offered_course)

    path = Attendances.get_offered_course_fill_attendance_path(offered_course.id)
    data = %{offered_course_name: "#{offered_course.term.name}-#{offered_course.course.name}"}
    insert(:notification, user_id: teacher.id, type: "attendance_missing", resource_path: path, data: data)

    {type, subject} = {:attendance_missing, "One or more attendances are not filled"}

    notification =
      Notifications.new()
      |> Notifications.to(@valid_user)
      |> Notifications.type(type)
      |> Notifications.resource_path(path)
      |> Notifications.add_data(data)
      |> Notifications.Notification.changeset()
      |> CoursePlanner.Repo.insert!

    email =
      Notifications.Notification
      |> CoursePlanner.Repo.get(notification.id)
      |> CoursePlanner.Repo.preload(:user)
      |> UserEmail.build_email()

    assert email.html_body =~ path
    assert email.html_body =~ data.offered_course_name

    Mailer.deliver(email)
    assert_email_sent subject: subject
  end

  test "build summary email" do
    vol = insert(:volunteer)
    insert(:notification, user_id: vol.id)
    insert(:notification, user_id: vol.id)
    insert(:notification, user_id: vol.id)

    User
    |> Repo.get(vol.id)
    |> Repo.preload(:notifications)
    |> UserEmail.build_summary()
    |> Mailer.deliver()

    assert_email_sent subject: "Activity Summary"
  end

  test "summary without notifications" do
    vol = insert(:teacher)

    result = User
    |> Repo.get(vol.id)
    |> Repo.preload(:notifications)
    |> UserEmail.build_summary()

    assert result == {:error, :empty_notifications}
  end
end
