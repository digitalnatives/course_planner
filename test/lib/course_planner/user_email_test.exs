defmodule CoursePlanner.UserEmailTest do
  use ExUnit.Case
  doctest CoursePlanner.Mailer.UserEmail

  alias CoursePlanner.{User, Mailer, Mailer.UserEmail, Notifier.Notification}
  import Swoosh.TestAssertions

  @valid_user %User{name: "mahname", email: "valid@email"}
  @invalid_user %User{name: "mahname"}
  @invalid_user2 %User{name: "mahname", email: nil}

  test "inexistent notification type" do
    assert UserEmail.build_email(%Notification{to: @valid_user, type: :sometype}) == {:error, :wrong_notification_type}
  end

  test "empty e-mail" do
    assert UserEmail.build_email(%Notification{to: @invalid_user, type: :user_modified}) == {:error, :invalid_recipient}
  end

  test "nil e-mail" do
    assert UserEmail.build_email(%Notification{to: @invalid_user2, type: :user_modified}) == {:error, :invalid_recipient}
  end

  for email <- [
    {:user_modified, "Your profile is updated"},
    {:course_updated, "A course you subscribed to was updated"},
    {:course_deleted, "A course you subscribed to was deleted"},
    {:term_updated, "A term you are enrolled in was updated"},
    {:term_deleted, "A term you are enrolled in was deleted"},
    {:class_subscribed, "You were subscribed to a class"},
    {:class_updated, "A class you subscribe to was updated"},
    {:class_deleted, "A class you subscribe to was deleted"}
    ] do
    @email email
    test "notify #{inspect @email}" do
      {type, subject} = @email
      Notification.new()
      |> Notification.to(@valid_user)
      |> Notification.type(type)
      |> UserEmail.build_email()
      |> Mailer.deliver()
      assert_email_sent subject: subject
    end
  end
end
