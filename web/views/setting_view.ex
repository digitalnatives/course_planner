defmodule CoursePlanner.SettingView do
  @moduledoc false
  use CoursePlanner.Web, :view

  def get_form_component_from_type(form, field, type, label) do
    case type do
      "text"    -> CoursePlanner.SharedView.form_textarea(form, field, label: label)
      "string"  -> CoursePlanner.SharedView.form_text(form, field, label: label)
      "url"     -> CoursePlanner.SharedView.form_text(form, field, label: label)
      "list"    -> CoursePlanner.SharedView.form_text(form, field, label: label)
      "integer" -> CoursePlanner.SharedView.form_text(form, field, label: label)
      "boolean" -> CoursePlanner.SharedView.form_select(form, field, ["True", "False"], label: label)
      _         -> render_default_setting_input(form)
    end
  end

  defp render_default_setting_input(form) do
    render "default_setting_input.html", form: form
  end
end
