defmodule CoursePlanner.SettingControllerTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlanner.Settings.SystemVariable
  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    conn =
      role
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  @moduletag user_role: :coordinator
  describe "settings functionality for coordinator user" do
    test "shows chosen resource only for coordinator", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      html_response = html_response(conn, 200)
      assert html_response =~ "System Settings"
      assert html_response =~ "Program Settings"
    end

    test "renders form for editing system setting for coordinator", %{conn: conn} do
      insert(:system_variable, type: "text", key: "text_type_system_setting", value: "")
      insert(:system_variable, type: "boolean", key: "boolean_type_system_setting", value: "false")
      insert(:system_variable, type: "timezone", key: "timezone_type_system_setting", value: "Europe/Budapest")

      conn = get conn, setting_path(conn, :edit, setting_type: "system")
      assert html_response(conn, 200) =~ "Edit system setting"
    end

    test "renders form for editing program setting for coordinator", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "program")
      assert html_response(conn, 200) =~ "Edit program setting"
    end

    test "renders 404 if request is notsystem_settings nor program_settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "random")
      assert html_response(conn, 404)
    end

    test "does not update chosen resource and renders errors when data is invalid for coordinator user", %{conn: conn} do
      edit_page_title = "Edit test"
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: ""}}, title: edit_page_title}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 200) =~ edit_page_title
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "updates chosen resource and redirects when data is valid for coordinator user", %{conn: conn} do
      system_variable = insert(:system_variable)
      updating_value = "new program name"
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: updating_value}}, title: "Edit settings"}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert redirected_to(conn) == setting_path(conn, :show)
      assert Repo.get(SystemVariable, system_variable.id).value == updating_value
    end

    test "does not update chosen resource when is not editable", %{conn: conn} do
      insert(:system_variable)
      system_variable = insert(:system_variable, %{editable: false})
      updating_value = "new program name"
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: updating_value}}, title: "random"}

      conn = put conn, setting_path(conn, :update), settings: updated_params

      assert html_response(conn, 403)
      refute Repo.get(SystemVariable, system_variable.id).value == updating_value
    end

    test "does not update chosen inexisting resource", %{conn: conn} do
      updated_params = %{system_variables: %{"0" => %{id: "-1", value: "random value"}}, title: "random"}

      conn = put conn, setting_path(conn, :update), settings: updated_params

      assert html_response(conn, 404)
    end
  end

  @moduletag user_role: :student
  describe "setting functionality for student user" do
    test "student can't see settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 403)
    end

    test "student cannot edit system settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "system")
      assert html_response(conn, 403)
    end

    test "student cannot edit program settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "program")
      assert html_response(conn, 403)
    end

    test "student can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end

  @moduletag user_role: :teacher
  describe "settings functionality for teacher user" do
    test "teacher can't see settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 403)
    end

    test "teacher cannot edit system settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "system")
      assert html_response(conn, 403)
    end

    test "teacher cannot edit program settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "program")
      assert html_response(conn, 403)
    end

    test "teacher can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end

  @moduletag user_role: :volunteer
  describe "settings functionality for volunteer user" do
    test "volunteer can't see settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 403)
    end

    test "volunteer cannot edit system settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "system")
      assert html_response(conn, 403)
    end

    test "volunteer cannot edit programsettings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "program")
      assert html_response(conn, 403)
    end

    test "volunteer can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end

  @moduletag user_role: :supervisor
  describe "settings functionality for supervisor user" do
    test "shows chosen resource", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      html_response = html_response(conn, 200)
      assert html_response =~ "System Settings"
      assert html_response =~ "Program Settings"
    end

    test "cannot edit system settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "system")
      assert html_response(conn, 403)
    end

    test "cannot edit programsettings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit, setting_type: "program")
      assert html_response(conn, 403)
    end

    test "can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end

end
