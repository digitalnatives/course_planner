defmodule CoursePlanner.SettingView do
  use CoursePlanner.Web, :view

  def get_error_message(errors) when is_list(errors) do
    {:value, {message, _}} = List.first(errors)
    message
  end
  def get_error_message(errors), do: ""

end
