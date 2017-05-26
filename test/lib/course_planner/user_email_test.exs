defmodule CoursePlanner.UserEmailTest do
  use ExUnit.Case
  doctest CoursePlanner.Mailer.UserEmail

  alias CoursePlanner.{User, Mailer, Mailer.UserEmail}
  import Swoosh.TestAssertions

  @valid_user %User{name: "mahname", email: "valid@email"}
  @invalid_user %User{name: "mahname"}
  @invalid_user2 %User{name: "mahname", email: nil}

  test "inexistent notification type" do
    assert UserEmail.build_email(@valid_user, :sometype) == {:error, :wrong_notification_type}
  end

  test "empty e-mail" do
    assert UserEmail.build_email(@invalid_user, :user_modified) == {:error, :invalid_recipient}
  end

  test "nil e-mail" do
    assert UserEmail.build_email(@invalid_user2, :user_modified) == {:error, :invalid_recipient}
  end

  test "notify user update" do
    @valid_user
    |> UserEmail.build_email(:user_modified)
    |> Mailer.deliver()
    assert_email_sent subject: "Your profile is updated"
  end

  test "notify term updated" do
    @valid_user
    |> UserEmail.build_email(:term_updated)
    |> Mailer.deliver()
    assert_email_sent subject: "A term you are enrolled in was updated"
  end

  test "notify term deleted" do
    @valid_user
    |> UserEmail.build_email(:term_deleted)
    |> Mailer.deliver()
    assert_email_sent subject: "A term you are enrolled in was deleted"
  end

  test "notify class subscription" do
    @valid_user
    |> UserEmail.build_email(:class_subscribed)
    |> Mailer.deliver()
    assert_email_sent subject: "You were subscribed to a class"
  end

  test "notify class updated" do
    @valid_user
    |> UserEmail.build_email(:class_updated)
    |> Mailer.deliver()
    assert_email_sent subject: "A class you subscribe to was updated"
  end

  test "notify class deleted" do
    @valid_user
    |> UserEmail.build_email(:class_deleted)
    |> Mailer.deliver()
    assert_email_sent subject: "A class you subscribe to was deleted"
  end
end
