defmodule CoursePlanner.SettingController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Settings, SystemVariable}
  alias Ecto.Changeset

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

  def edit(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn,
           %{"setting_type" =>  setting_type}) do
    editable_system_variables = Settings.get_editable_systemvariables()

    case Settings.filter_system_variables(editable_system_variables, setting_type) do
     {:ok, filtered_system_variables} ->
       title = "Edit #{setting_type} setting"

       changeset =
         filtered_system_variables
         |> Enum.map(&SystemVariable.changeset/1)
         |> Settings.wrap()

       render(conn, "edit.html", changeset: changeset, title: title)
     {:error, _} ->
       conn
       |> put_status(404)
       |> render(CoursePlanner.ErrorView, "404.html")
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
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, :uneditable_resource, _failed_value, _changes_so_far} ->
        conn
        |> put_status(403)
        |> render(CoursePlanner.ErrorView, "403.html")
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
