defmodule CoursePlanner.Email do
  import Bamboo.Email

  def welcome_email do
    new_email()
    |> to("rodrigo.nonose@digitalnatives.hu")
    |> from("idunnolol@mahapp.com")
    |> subject("Ayy lmao.")
    |> html_body("<strong>ayy</strong>")
    |> text_body("lmao")
  end
end
