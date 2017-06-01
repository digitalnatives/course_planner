defmodule CoursePlanner.TermView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.Terms.{Term, Holiday}
  alias Phoenix.HTML.{Form, FormData}

  def link_to_holiday_fields(form, field) do
    link(
      "Add Holiday",
      to: "#",
      data:
        [
          template: holiday_fields_template(),
          index: add_link_index(form, field),
          container: container_id(form, field)
        ],
      class: "add-form-field")
  end

  defp holiday_fields_template do
    changeset = Term.changeset(%Term{holidays: [%Holiday{}]})
    template_form = FormData.to_form(changeset, [])
    render_to_string(__MODULE__, "holiday_fields.html", f: template_form)
  end

  defp add_link_index(form, field) do
    add_link_index(Form.input_value(form, field) || [])
  end

  defp add_link_index(field_values) when is_list(field_values) do
    length(field_values)
  end

  defp add_link_index(field_values) when is_map(field_values) do
    last_index =
      field_values
      |> Map.keys()
      |> Enum.map(&String.to_integer/1)
      |> Enum.max

    last_index + 1
  end

  defp container_id(form, field) do
    id = Form.input_id(form, field)
    id <> "_nested_form"
  end
end
