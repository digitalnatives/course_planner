defmodule CoursePlanner.SettingController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Settings, SystemVariable}

  import Canary.Plugs
  plug :authorize_controller

  def show(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, _param) do
    visible_system_variables = Settings.get_visible_systemvariables()
    program_system_variables =
      Settings.filter_program_systemvariables(visible_system_variables)
    non_program_system_variables =
      Settings.filter_non_program_systemvariables(visible_system_variables)

    render(conn, "show.html", program_system_variables: program_system_variables,
                              non_program_system_variables: non_program_system_variables)
  end

  def edit(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, param) do
    editable_system_variables = Settings.get_editable_systemvariables()

    filtered_system_variables =
      case Map.get(param, "setting_type") do
        "system_settings"  -> Settings.filter_non_program_systemvariables(editable_system_variables)
        "program_settings" -> Settings.filter_program_systemvariables(editable_system_variables)
        _                  -> nil
      end

    case filtered_system_variables do
      nil ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      _   ->
        changeset =
          filtered_system_variables
          |> Enum.map(&SystemVariable.changeset/1)
          |> Settings.wrap()

        render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(
    %{assigns: %{current_user: %{role: "Coordinator"}}} = conn,
    %{"settings" => %{"system_variables" => variables}}) do
    changesets = Settings.get_changesets_for_update(variables)

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
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        changeset =
          changesets
          |> Settings.wrap()
          |> Map.put(:action, :update)
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
