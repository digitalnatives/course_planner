defmodule CoursePlanner.Mailer.UserEmail do
  import Swoosh.Email

  @type recipient_name :: String.t
  @type recipient_email :: String.t
  @type recipient_info :: {recipient_name, recipient_email}
  @type target_group :: :to | :cc | :bcc

  def welcome(user) do
    {"Dr B Banner", "hulk.smash@example.com"}
    |> create_empty_email()
    |> add_recepients(:to, {user.name, user.email})
    |> subject("Hello, Avengers!")
    |> html_body("<h1>Hello #{user.name}</h1>")
    |> text_body("Hello #{user.name}\n")
  end


  @spec add_recepients(Swoosh.Email, target_group, [recipient_info]) :: Swoosh.Email
  def add_recepients(email, target_group, recipient_list) when is_list(recipient_list) do
    Map.update!(email, target_group, &(&1 = recipient_list))
  end
  @spec add_recepients(Swoosh.Email, target_group, recipient_info) :: Swoosh.Email
  def add_recepients(email, target_group, recipient) do
    Map.update!(email, target_group, &(&1 = [recipient]))
  end

  @spec create_empty_email(recipient_info) :: Swoosh.Email
  def create_empty_email(sender_info) do
    new()
    |> from(sender_info)
  end
end
