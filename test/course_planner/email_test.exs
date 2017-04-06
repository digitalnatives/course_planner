defmodule CoursePlanner.EmailTest do
  use ExUnit.Case
  use Bamboo.Test
  alias CoursePlanner.{Email, Mailer}

  test "test delivery" do
    Email.welcome_email()
      |> Mailer.deliver_now()

    assert_delivered_email Email.welcome_email()
  end
end
