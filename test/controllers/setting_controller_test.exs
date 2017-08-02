defmodule CoursePlanner.SettingControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.SystemVariable
  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  describe "settings functionality for coordinator user" do
    @tag user_role: :coordinator
    test "shows chosen resource only for coordinator", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 200) =~ "Settings"
    end

    @tag user_role: :coordinator
    test "renders form for editing for coordinator", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit)
      assert html_response(conn, 200) =~ "Settings"
    end

    @tag user_role: :coordinator
    test "does not update chosen resource and renders errors when data is invalid for coordinator user", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: ""}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 200) =~ "Settings"
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    @tag user_role: :coordinator
    test "updates chosen resource and redirects when data is valid for coordinator user", %{conn: conn} do
      system_variable = insert(:system_variable)
      updating_value = "new program name"
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: updating_value}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert redirected_to(conn) == setting_path(conn, :show)
      assert Repo.get(SystemVariable, system_variable.id).value == updating_value
    end

    @tag user_role: :coordinator
    test "does not update chosen resource when is not editable", %{conn: conn} do
      insert(:system_variable)
      system_variable = insert(:system_variable, %{editable: false})
      updating_value = "new program name"
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: updating_value}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params

      assert html_response(conn, 403)
      refute Repo.get(SystemVariable, system_variable.id).value == updating_value
    end

    @tag user_role: :coordinator
    test "does not update chosen inexisting resource", %{conn: conn} do
      updated_params = %{system_variables: %{"0" => %{id: "-1", value: "random value"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params

      assert html_response(conn, 404)
    end
  end

  describe "setting functionality for student user" do
    @tag user_role: :student
    test "student can't see settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 403)
    end

    @tag user_role: :student
    test "student cannot edit settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit)
      assert html_response(conn, 403)
    end

    @tag user_role: :student
    test "student can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end

  describe "settings functionality for teacher user" do
    @tag user_role: :teacher
    test "teacher can't see settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "teacher cannot edit settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit)
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "teacher can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end

  describe "settings functionality for volunteer user" do
    @tag user_role: :volunteer
    test "volunteer can't see settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :show)
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "volunteer cannot edit settings", %{conn: conn} do
      conn = get conn, setting_path(conn, :edit)
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "volunteer can't update settings", %{conn: conn} do
      system_variable = insert(:system_variable)
      updated_params = %{system_variables: %{"0" => %{id: "#{system_variable.id}", value: "new program name"}}}

      conn = put conn, setting_path(conn, :update), settings: updated_params
      assert html_response(conn, 403)
    end
  end
end
