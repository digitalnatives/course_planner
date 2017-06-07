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

  def form_text(form, field, label, opts \\ []) do
    class = opts[:class] || ""
    render "form_text.html", form: form, field: field, label: label, class: class
  end

  def form_password(form, field, label, opts  \\ []) do
    class = opts[:class] || ""
    render "form_password.html", form: form, field: field, label: label, class: class
  end

  def form_submit(form, label, opts \\ []) do
    class = opts[:class] || ""
    render "form_submit.html", form: form, label: label, class: class
  end

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
