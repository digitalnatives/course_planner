defmodule CoursePlanner.SettingController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Settings, SystemVariable}

  import Canary.Plugs
  plug :authorize_controller

  def show(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, _param) do
    system_variables = Settings.get_visible_systemvariables()
    render(conn, "show.html", system_variables: system_variables)
  end

  def edit(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, _param) do
    variables = Settings.get_editable_systemvariables()
    changesets = Enum.map(variables, fn(variable) -> SystemVariable.changeset(variable) end)

    render(conn, "edit.html", system_variable_changesets: changesets, errors: [])
  end

  def update(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, %{"settings" => setting_params}) do
    changesets =
      Settings.get_changesets_for_update(setting_params)
      |> Enum.sort_by &(&1.data.key)

    case Settings.update(changesets) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: setting_path(conn, :show))
      {:error, :non_existing_resource, _failed_value, _changes_so_far} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, :uneditable_resource, _failed_value, _changes_so_far} ->
        conn
        |> put_status(403)
        |> render(CoursePlanner.ErrorView, "403.html")
      {:error, failed_operation, failed_value, _changes_so_far} ->
        [value: {error_message, _}] = failed_value.errors
        error = %{field: failed_operation, message: error_message}
        render(conn, "edit.html", system_variable_changesets: changesets, errors: [error])
    end
  end
end
