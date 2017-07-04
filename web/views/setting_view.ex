defmodule CoursePlanner.SettingView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.Settings

  def integer_to_atom(input) do
    input
    |> Integer.to_string()
    |> String.to_atom()
  end

  def populate_error_to_form(form, group_id, error) do
    Settings.insert_error(form, group_id, error)
  end
end
