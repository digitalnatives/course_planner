defmodule CoursePlanner.SettingView do
  @moduledoc false
  use CoursePlanner.Web, :view
  alias CoursePlanner.SharedView

  def setting_input(form, field, type, label) do
    case type do
      "text"    -> SharedView.form_textarea(form, field, label: label)
      "boolean" -> SharedView.form_select(form, field, ["True", "False"], label: label)
      _         -> SharedView.form_text(form, field, label: label)
    end
  end
end
