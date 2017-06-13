defmodule CoursePlanner.SharedView do
  use CoursePlanner.Web, :view

  # helpers

  def path_exact_match(conn, path) do
    conn.request_path == path
  end

  def path_match(conn, path) do
    String.starts_with? conn.request_path, path
  end

  # form components

  def form_text(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    wrapper_class = ""

    if form.errors[field] do
      wrapper_class = "is-invalid"
    end

    required = opts[:required] || nil

    value = Map.get form.data, field
    if required && String.length to_string value > 0 do
      wrapper_class = Enum.join [wrapper_class, "form-init"], " "
    end

    render "form_text.html", form: form,
                             field: field,
                             label: label,
                             wrapper_class: wrapper_class,
                             class: class,
                             required: required
  end

  def form_textarea(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    wrapper_class = ""

    if form.errors[field] do
      wrapper_class = "is-invalid"
    end

    required = opts[:required] || nil

    value = Map.get form.data, field
    if required && String.length to_string value > 0 do
      wrapper_class = Enum.join [wrapper_class, "form-init"], " "
    end

    rows = opts[:rows] || 3

    render "form_textarea.html", form: form,
                                 field: field,
                                 label: label,
                                 wrapper_class: wrapper_class,
                                 class: class,
                                 required: required,
                                 rows: rows
  end

  def form_password(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    required = opts[:required] || nil
    wrapper_class = ""

    value = Map.get form.data, field
    if required && String.length to_string value > 0 do
      wrapper_class = Enum.join [wrapper_class, "form-init"], " "
    end

    render "form_password.html", form: form,
                                 field: field,
                                 label: label,
                                 wrapper_class: wrapper_class,
                                 class: class,
                                 required: required
  end

  def form_date(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)

    render "form_date.html", form: form,
                             field: field,
                             label: label,
                             class: class
  end

  def form_time(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)

    render "form_time.html", form: form,
                             field: field,
                             label: label,
                             class: class
  end

  def form_datetime(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)

    render "form_datetime.html", form: form,
                                 field: field,
                                 label: label,
                                 class: class
  end

  def form_select(form, field, options, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    selected = opts[:selected] || nil

    render "form_select.html", form: form,
                               field: field,
                               label: label,
                               selected: selected,
                               options: options,
                               class: class
  end

  def form_multiselect(form, field, options, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    selected = opts[:selected] || nil
    tooltip_text = opts[:tooltip_text] || "Add new item"

    multiselect_id = (Atom.to_string field) <> "__multiselect"
    button_id = (Atom.to_string field) <> "__add-button"

    render "form_multiselect.html", form: form,
                                    field: field,
                                    label: label,
                                    selected: selected,
                                    options: options,
                                    tooltip_text: tooltip_text,
                                    class: class,
                                    button_id: button_id,
                                    multiselect_id: multiselect_id
  end

  def form_button(label, to, opts \\ []) do
    class = opts[:class] || ""
    render "form_button.html", label: label, to: to, class: class
  end

  def form_submit(form, label, opts \\ []) do
    class = opts[:class] || ""
    render "form_submit.html", form: form, label: label, class: class
  end

  # card

  def card(title, [do: children]) do
    render "card.html", title: title, children: children
  end

  def card_content([do: children]) do
    render "card_content.html", children: children
  end

  def card_actions([do: children]) do
    render "card_actions.html", children: children
  end

  # navbar

  def navbar(title, [do: children]) do
    render "navbar.html", title: title, children: children
  end

  def navbar_item(label, conn, path) do
    classes = if path_match(conn, path) do
      "mdl-navigation__link mdl-navigation__link--current"
    else
      "mdl-navigation__link"
    end

    render "navbar_item.html", label: label, path: path, classes: classes
  end

end
