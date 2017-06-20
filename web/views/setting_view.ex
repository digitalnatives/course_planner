defmodule CoursePlanner.SettingView do
  use CoursePlanner.Web, :view

  def to_atom(input) do
    input
    |> Integer.to_string()
    |> String.to_atom()
  end

end
