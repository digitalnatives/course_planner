defmodule CoursePlanner.SettingView do
  @moduledoc false
  use CoursePlanner.Web, :view
  alias CoursePlanner.SharedView

  def get_form_component_from_type(form, field, type, label) do
    case type do
      "text"    -> SharedView.form_textarea(form, field, label: label)
      "string"  -> SharedView.form_text(form, field, label: label)
      "url"     -> SharedView.form_text(form, field, label: label)
      "list"    -> SharedView.form_text(form, field, label: label)
      "integer" -> SharedView.form_text(form, field, label: label)
      "boolean" -> SharedView.form_select(form, field, ["True", "False"], label: label)
      _         -> render_default_setting_input(form)
    end
  end

  defp render_default_setting_input(form) do
    render "default_setting_input.html", form: form
  end

  def title do
    "Settings"
  end
end
