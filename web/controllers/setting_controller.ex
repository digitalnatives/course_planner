defmodule CoursePlanner.SettingController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Setting
#
  import Canary.Plugs
  plug :authorize_resource, model: Setting, non_id_actions: [:show, :edit, :update]

  def show(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, _param) do
    setting = Repo.one!(Setting)
    render(conn, "show.html", setting: setting)
  end

  def edit(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, _param) do
    setting = Repo.one!(Setting)
    changeset = Setting.changeset(setting)
    render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  def update(%{assigns: %{current_user: %{role: "Coordinator"}}} = conn, %{"setting" => setting_params}) do
    setting = Repo.one!(Setting)
    changeset = Setting.changeset(setting, setting_params)

    case Repo.update(changeset) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: setting_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", setting: setting, changeset: changeset)
    end
  end
end
