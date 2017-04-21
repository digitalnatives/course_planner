defmodule CoursePlanner.UserTest do
  use ExUnit.Case, async: true

  import Swoosh.TestAssertions

  test "sends welcome email" do
    user = %{name: "ironman", email: "tony.stark@example.com"}
    email = CoursePlanner.Mailer.UserEmail.welcome(user)
    CoursePlanner.Mailer.deliver(email)
    assert_email_sent email
  end


  test "create empty email" do
    user = {"ironman","tony.stark@example.com"}
    email = CoursePlanner.Mailer.UserEmail.create_empty_email(user)

    t_email =
     Swoosh.Email.new()
     |> Swoosh.Email.from(user)

    assert email == t_email
  end

  test "add recepients in :to part of the email" do
    targets = [{"1", "a@a.com"}, {"2", "b@b.com"}, {"3", "c@c.com"}]
    user = {"ironman","tony.stark@example.com"}
    email =
      user
      |> CoursePlanner.Mailer.UserEmail.create_empty_email()
      |> CoursePlanner.Mailer.UserEmail.add_recepients(:to, targets)

    t_email =
     Swoosh.Email.new()
     |> Swoosh.Email.from(user)
     |> Swoosh.Email.to(targets)

    assert email == t_email
  end

  test "add recepients in :cc part of the email" do
    targets = [{"1", "a@a.com"}, {"2", "b@b.com"}, {"3", "c@c.com"}]
    user = {"ironman","tony.stark@example.com"}
    email =
      user
      |> CoursePlanner.Mailer.UserEmail.create_empty_email()
      |> CoursePlanner.Mailer.UserEmail.add_recepients(:cc, targets)

    t_email =
     Swoosh.Email.new()
     |> Swoosh.Email.from(user)
     |> Swoosh.Email.cc(targets)

    assert email == t_email
  end

  test "add recepients in :bcc part of the email" do
    targets = [{"1", "a@a.com"}, {"2", "b@b.com"}, {"3", "c@c.com"}]
    user = {"ironman","tony.stark@example.com"}
    email =
      user
      |> CoursePlanner.Mailer.UserEmail.create_empty_email()
      |> CoursePlanner.Mailer.UserEmail.add_recepients(:bcc, targets)

    t_email =
     Swoosh.Email.new()
     |> Swoosh.Email.from(user)
     |> Swoosh.Email.bcc(targets)

    assert email == t_email
  end

  test "add recepients in :to, :cc and :bcc parts of the email" do
    targets = [{"1", "a@a.com"}, {"2", "b@b.com"}, {"3", "c@c.com"}]
    user = {"ironman","tony.stark@example.com"}
    email =
      user
      |> CoursePlanner.Mailer.UserEmail.create_empty_email()
      |> CoursePlanner.Mailer.UserEmail.add_recepients(:to, targets)
      |> CoursePlanner.Mailer.UserEmail.add_recepients(:cc, targets)
      |> CoursePlanner.Mailer.UserEmail.add_recepients(:bcc, targets)

    t_email =
     Swoosh.Email.new()
     |> Swoosh.Email.from(user)
     |> Swoosh.Email.to(targets)
     |> Swoosh.Email.cc(targets)
     |> Swoosh.Email.bcc(targets)

    assert email == t_email
  end
end
