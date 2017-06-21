defmodule CoursePlanner.SettingView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.Settings

  def integer_to_atom(input) do
    input
    |> Integer.to_string()
    |> String.to_atom()
  end

  def populate_errors_to_form(form, errors)
    when is_list(errors) and length(errors) > 0 do
    Settings.insert_error(form, errors)
  end
  def populate_errors_to_form(form, _), do: form
end
