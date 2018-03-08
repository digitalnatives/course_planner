defmodule CoursePlanner.AuthUserEmailTest do
  use ExUnit.Case

  alias CoursePlanner.Accounts.User
  alias CoursePlannerWeb.Auth.UserEmail

  @sample_url "http://www.sample-url.com"
  @valid_user %User{name: "mahname", email: "valid@email", role: "Student"}

  defp email_from do
    {
      Application.get_env(:course_planner, :auth_email_from_name),
      Application.get_env(:course_planner, :auth_email_from_email)
    }
  end

  test "Welcome email" do
    email = UserEmail.welcome(@valid_user, @sample_url)

    assert email.assigns.name == "mahname"
    assert email.assigns.role == "Student"
    assert email.assigns.url == "http://www.sample-url.com"
    assert email.assigns.site_name  == "CoursePlanner"
    assert email.from == {"Test Name", "test@email"}
    assert email.html_body =~ "Welcome to CoursePlanner!"
  end

  test "Reset password email" do
    email = UserEmail.password(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == email_from()
    assert email.html_body    =~ "- Reset password instructions"
  end

  test "confirmation email" do
    email = UserEmail.confirmation(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == email_from()
    assert email.html_body    =~ "- Confirm your new account"
  end

  test "invitation email" do
    email = UserEmail.invitation(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == email_from()
    assert email.html_body    =~ "- Invitation to create a new account"
  end

  test "unlock instruction email" do
    email = UserEmail.unlock(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == email_from()
    assert email.html_body    =~ "- Unlock Instructions"
  end

  describe "add_reply_to" do
    test "when setting is a string" do
      Application.put_env(:course_planner, :auth_email_reply_to, "reply@sample.com")
      email = UserEmail.welcome(@valid_user, @sample_url)

      assert email.assigns.name == "mahname"
      assert email.assigns.role == "Student"
      assert email.assigns.url == "http://www.sample-url.com"
      assert email.assigns.site_name  == "CoursePlanner"
      assert email.from == {"Test Name", "test@email"}
      assert email.reply_to == {"", "reply@sample.com"}
      assert email.html_body =~ "Welcome to CoursePlanner!"
    end

    test "when setting is a tuple" do
      Application.put_env(:course_planner, :auth_email_reply_to, {"reply_name","reply@sample.com"})
      email = UserEmail.welcome(@valid_user, @sample_url)

      assert email.assigns.name == "mahname"
      assert email.assigns.role == "Student"
      assert email.assigns.url == "http://www.sample-url.com"
      assert email.assigns.site_name  == "CoursePlanner"
      assert email.from == {"Test Name", "test@email"}
      assert email.reply_to == {"reply_name", "reply@sample.com"}
      assert email.html_body =~ "Welcome to CoursePlanner!"
    end

    test "when setting is true" do
      expected_reply_to_tuple =
      {
        Application.get_env(:course_planner, :auth_email_from_name),
        Application.get_env(:course_planner, :auth_email_from_email)
      }

      Application.put_env(:course_planner, :auth_email_reply_to, true)
      email = UserEmail.welcome(@valid_user, @sample_url)

      assert email.assigns.name == "mahname"
      assert email.assigns.role == "Student"
      assert email.assigns.url == "http://www.sample-url.com"
      assert email.assigns.site_name  == "CoursePlanner"
      assert email.from == {"Test Name", "test@email"}
      assert email.reply_to == expected_reply_to_tuple
      assert email.html_body =~ "Welcome to CoursePlanner!"
    end
  end
end
