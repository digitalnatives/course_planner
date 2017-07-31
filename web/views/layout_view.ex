defmodule CoursePlanner.LayoutView do
  @moduledoc false
  use CoursePlanner.Web, :view

  alias CoursePlanner.Settings

  def show_program_about? do
    Settings.get_value("SHOW_PROGRAM_ABOUT_PAGE")
  end

  def get_program_name do
    Settings.get_value("PROGRAM_NAME")
  end
end
