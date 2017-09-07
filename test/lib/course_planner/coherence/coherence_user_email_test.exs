defmodule CoursePlanner.CoherenceUserEmailTest do
  use ExUnit.Case

  alias CoursePlanner.Accounts.User
  alias CoursePlannerWeb.Coherence.UserEmail
  alias Coherence.Config

  @sample_url "http://www.sample-url.com"
  @valid_user %User{name: "mahname", email: "valid@email", role: "Student"}

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
    assert email.from         == Config.email_from
    assert email.html_body    =~ "- Reset password instructions"
  end

  test "confirmation email" do
    email = UserEmail.confirmation(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == Config.email_from
    assert email.html_body    =~ "- Confirm your new account"
  end

  test "invitation email" do
    email = UserEmail.invitation(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == Config.email_from
    assert email.html_body    =~ "- Invitation to create a new account"
  end

  test "unlock instruction email" do
    email = UserEmail.unlock(@valid_user, @sample_url)

    assert email.assigns.name == @valid_user.name
    assert email.assigns.url  == @sample_url
    assert email.from         == Config.email_from
    assert email.html_body    =~ "- Unlock Instructions"
  end
end
