defmodule CoursePlanner.UserEmailTest do
  use ExUnit.Case
  doctest CoursePlanner.Mailer.UserEmail

  alias CoursePlanner.{User, Mailer, Mailer.UserEmail}
  import Swoosh.TestAssertions

  @valid_user %User{name: "mahname", email: "valid@email"}
  @invalid_user %User{name: "mahname"}

  test "inexistent notification type" do
    assert UserEmail.build_email(@valid_user, :sometype) == {:error, :wrong_notification_type}
  end

  test "invalid user" do
    assert UserEmail.build_email(@invalid_user, :user_modified) == {:error, :invalid_recipient}
  end

  test "notify user update" do
    @valid_user
    |> UserEmail.build_email(:user_modified)
    |> Mailer.deliver()
    assert_email_sent subject: "Your profile was updated"
  end

  test "notify enrollment to term" do
    @valid_user
    |> UserEmail.build_email(:term_enrolled)
    |> Mailer.deliver()
    assert_email_sent subject: "You were enrolled to a term"
  end

end
