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

    render(conn, "edit.html", system_variable_changesets: changesets)
  end

  def update(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, %{"setting" => setting_params}) do
    system_variables = Settings.get_editable_systemvariables()

    changesets =
      Enum.map(system_variables, fn(system_variable) ->
        setting_id = to_string(system_variable.id)
        param = Map.get(setting_params, setting_id)
        SystemVariable.changeset(system_variable, param, :update)
      end)

    case Settings.update(changesets) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: setting_path(conn, :show))
      {:error, failed_operation, failed_value, changes_so_far} ->
        render(conn, "edit.html", system_variable_changesets: changesets)
    end
  end
end
