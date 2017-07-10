defmodule CoursePlanner.SharedView do
  @moduledoc false
  use CoursePlanner.Web, :view

  # helpers

  def path_exact_match(conn, path) do
    conn.request_path == path
  end

  def path_match(conn, path) do
    String.starts_with? conn.request_path, path
  end

  def get_gravatar_url(email, size \\ 100) do
    hash =
      :md5
      |> :crypto.hash(email)
      |> Base.encode16()
      |> String.downcase()

    "https://www.gravatar.com/avatar/#{hash}?d=mm&s=#{size}"
  end

  # form components

  def form_text(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    required = opts[:required] || nil
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    value = Map.get form.data, field
    wrapper_class =
      if error do
        "is-invalid"
      else
        if required && String.length to_string value > 0 do
          "form-init"
        else
          ""
        end
      end

    render "form_text.html", form: form,
                             field: field,
                             label: label,
                             error: error,
                             wrapper_class: wrapper_class,
                             class: class,
                             required: required
  end

  def form_textarea(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    required = opts[:required] || nil
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    value = Map.get form.data, field
    wrapper_class =
      if error do
        "is-invalid"
      else
        if required && String.length to_string value > 0 do
          "form-init"
        else
          ""
        end
      end

    rows = opts[:rows] || 3

    render "form_textarea.html", form: form,
                                 field: field,
                                 label: label,
                                 error: error,
                                 wrapper_class: wrapper_class,
                                 class: class,
                                 required: required,
                                 rows: rows
  end

  def form_password(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    required = opts[:required] || nil
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    wrapper_class =
      if error do
        "is-invalid"
      else
        if required do "form-init" else "" end
      end

    render "form_password.html", form: form,
                                 field: field,
                                 label: label,
                                 error: error,
                                 wrapper_class: wrapper_class,
                                 class: class,
                                 required: required
  end

  def form_date(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    wrapper_class = if error do "is-invalid" else "" end

    render "form_date.html", form: form,
                             field: field,
                             label: label,
                             error: error,
                             wrapper_class: wrapper_class,
                             class: class
  end

  def form_time(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    wrapper_class = if error do "is-invalid" else "" end

    render "form_time.html", form: form,
                             field: field,
                             label: label,
                             error: error,
                             wrapper_class: wrapper_class,
                             class: class
  end

  def form_datetime(form, field, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    wrapper_class = if error do "is-invalid" else "" end

    render "form_datetime.html", form: form,
                                 field: field,
                                 label: label,
                                 error: error,
                                 wrapper_class: wrapper_class,
                                 class: class
  end

  def form_select(form, field, options, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    selected = opts[:selected] || nil
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    wrapper_class = if error do "is-invalid" else "" end

    render "form_select.html", form: form,
                               field: field,
                               label: label,
                               error: error,
                               selected: selected,
                               options: options,
                               wrapper_class: wrapper_class,
                               class: class
  end

  def form_multiselect(form, field, options, opts \\ []) do
    class = opts[:class] || ""
    label = opts[:label] || humanize(field)
    selected = opts[:selected] || nil
    tooltip_text = opts[:tooltip_text] || "Add new item"
    {error, _} = Keyword.get form.errors, field, {nil, nil}

    multiselect_id = (Atom.to_string field) <> "__multiselect"
    button_id = (Atom.to_string field) <> "__add-button"

    wrapper_class = if error do "is-invalid" else "" end

    display_images = opts[:display_images] || false

    render "form_multiselect.html", form: form,
                                    field: field,
                                    label: label,
                                    error: error,
                                    selected: selected,
                                    options: options,
                                    tooltip_text: tooltip_text,
                                    wrapper_class: wrapper_class,
                                    class: class,
                                    display_images: display_images,
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

  def card(title \\ nil, opts \\ [], [do: children]) do
    title_class =
      if opts[:highlighted_title] do
        "card__title--highlighted"
      else
        ""
      end

    render "card.html", title: title,
                        title_class: title_class,
                        children: children
  end

  def card_content(opts \\ [], [do: children]) do
    class =
      if opts[:vpadding] do
        "card__content--vpadding"
      else
        ""
      end

    render "card_content.html", children: children,
                                class: class
  end

  def card_actions([do: children]) do
    render "card_actions.html", children: children
  end

  # navbar

  def navbar(title, [do: children]) do
    render "navbar.html", title: title, children: children
  end

  def navbar_separator do
    render "navbar_separator.html"
  end

  def navbar_item(label, conn, path) do
    classes = if path_match(conn, path) do
      "mdl-navigation__link mdl-navigation__link--current"
    else
      "mdl-navigation__link"
    end

    render "navbar_item.html", label: label, path: path, classes: classes
  end

  # show pages

  def user_list(users, opts \\ []) do
    empty_text = opts[:empty_text] || "There are no users here yet"
    render "user_list.html", users: users,
                             empty_text: empty_text
  end

  def user_bubble(user) do
    profile_picture = get_gravatar_url(user.email, 200)

    name = [user.name, user.family_name, user.nickname && "(#{user.nickname})"]
      |> Enum.filter(fn v -> String.length(to_string v) > 0 end)
      |> Enum.join(" ")

    url = user_show_path(user)

    render "user_bubble.html", url: url,
                               profile_picture: profile_picture,
                               name: name
  end

  def class_list(classes, opts \\ []) do
    empty_text = opts[:empty_text] || "There are no classes here yet"
    show_attendances = opts[:show_attendances] || false

    render "class_list.html", classes: classes,
                              empty_text: empty_text,
                              show_attendances: show_attendances
  end

  def course_list(offered_courses, opts \\ []) do
    empty_text = opts[:empty_text] || "There are no courses here yet"

    render "course_list.html", offered_courses: offered_courses,
                               empty_text: empty_text
  end

  def task_list(tasks, opts \\ []) do
    empty_text = opts[:empty_text] || "There are no tasks here yet"

    render "task_list.html", tasks: tasks,
                             empty_text: empty_text
  end

  def holiday_list(holidays, opts \\ []) do
    empty_text = opts[:empty_text] || "There are no holidays here yet"

    render "holiday_list.html", holidays: holidays,
                                empty_text: empty_text
  end

end
