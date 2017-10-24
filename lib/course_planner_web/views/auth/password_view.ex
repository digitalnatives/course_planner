defmodule CoursePlannerWeb.Auth.PasswordView do
  @moduledoc false
  use CoursePlannerWeb, :view

  def error_tag(errors, field) when is_list(errors) and is_atom(field) do
    case Keyword.fetch(errors, field) do
      {:ok, message} ->
        field_error_message = "#{humanize(field)} #{translate_error(message)}"
        content_tag(:span, field_error_message, class: "login__error")
      :error ->
        html_escape("")
    end
  end
end
