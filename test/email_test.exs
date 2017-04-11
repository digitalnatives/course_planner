defmodule CoursePlanner.UserTest do
  use ExUnit.Case, async: true

  import Swoosh.TestAssertions

  test "sends welcome email" do
    user = %{name: "ironman", email: "tony.stark@example.com"}
    email = CoursePlanner.Mailer.UserEmail.welcome(user)
    CoursePlanner.Mailer.Main.deliver(email)
    assert_email_sent email
  end
end
