defmodule CoursePlanner.ErrorView do
  use CoursePlanner.Web, :view

  def render("403.html", _assigns), do: "Forbidden"

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("401.json", _assigns), do: "Unauthorized"

  def render("406.json", assigns) do
    json_errors =
      Enum.map(assigns.conn.errors, fn({error_field, {error_message, _}}) ->
        %{error_field => error_message}
      end)
    %{error: json_errors}
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
