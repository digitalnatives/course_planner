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

  test "notify user update" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:user_modified)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "Your profile is updated"
  end

  test "notify course update" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:course_updated)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "A course you subscribed to was updated"
  end

  test "notify course deleted" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:course_deleted)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "A course you subscribed to was deleted"
  end

  test "notify term updated" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:term_updated)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "A term you are enrolled in was updated"
  end

  test "notify term deleted" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:term_deleted)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "A term you are enrolled in was deleted"
  end

  test "notify class subscription" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:class_subscribed)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "You were subscribed to a class"
  end

  test "notify class updated" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:class_updated)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "A class you subscribe to was updated"
  end

  test "notify class deleted" do
    Notification.new()
    |> Notification.to(@valid_user)
    |> Notification.type(:class_deleted)
    |> UserEmail.build_email()
    |> Mailer.deliver()
    assert_email_sent subject: "A class you subscribe to was deleted"
  end
end
