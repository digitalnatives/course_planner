defmodule CoursePlannerWeb.SettingController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.Settings
  alias Ecto.Changeset

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

  def show(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, _param) do
    visible_system_variables = Settings.get_visible_systemvariables()
    program_system_variables =
      Settings.filter_program_systemvariables(visible_system_variables)
    non_program_system_variables =
      Settings.filter_non_program_systemvariables(visible_system_variables)

    render(conn, "show.html", program_system_variables: program_system_variables,
                              non_program_system_variables: non_program_system_variables)
  end

  def edit(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn,
           %{"setting_type" =>  setting_type}) do
    with editable_system_variables <- Settings.get_editable_systemvariables(),
         {:ok, filtered_system_variables} <-
           Settings.filter_system_variables(editable_system_variables, setting_type),
         changeset <- Settings.get_changeset(filtered_system_variables)
    do
       render(conn, "edit.html", changeset: changeset, title: "Edit #{setting_type} setting")
    end
  end

  def update(
    %{assigns: %{current_user: %{role: "Coordinator"}}} = conn,
    %{"settings" => %{"system_variables" => variables, "title" => title}}) do
    changesets = Settings.get_changesets_for_update(variables)

    case Settings.update(changesets) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: setting_path(conn, :show))
      {:error, :non_existing_resource, _failed_value, _changes_so_far} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
      {:error, :uneditable_resource, _failed_value, _changes_so_far} ->
        conn
        |> put_status(403)
        |> render(CoursePlannerWeb.ErrorView, "403.html")
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        changeset =
          changesets
          |> Enum.sort_by(&(Changeset.get_field(&1, :key)), &<=/2)
          |> Settings.wrap()
          |> Map.put(:action, :update)
        render(conn, "edit.html", changeset: changeset, title: title)
    end
  end
end
