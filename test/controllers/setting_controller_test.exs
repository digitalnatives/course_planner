defmodule CoursePlanner.SettingControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.SystemVariable
  import CoursePlanner.Factory

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "shows chosen resource only for coordinator", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    conn = get coordinator_conn, setting_path(coordinator_conn, :show)
    assert html_response(conn, 200) =~ "Show settings"
  end

  test "does not show chosen resource for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, setting_path(student_conn, :show)
    assert html_response(conn, 403)

    conn = get teacher_conn, setting_path(teacher_conn, :show)
    assert html_response(conn, 403)

    conn = get volunteer_conn, setting_path(volunteer_conn, :show)
    assert html_response(conn, 403)
  end

  test "renders form for editing for coordinator", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    conn = get coordinator_conn, setting_path(coordinator_conn, :edit)
    assert html_response(conn, 200) =~ "Edit settings"
  end

  test "does not renders form for editing for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, setting_path(student_conn, :edit)
    assert html_response(conn, 403)

    conn = get teacher_conn, setting_path(teacher_conn, :edit)
    assert html_response(conn, 403)

    conn = get volunteer_conn, setting_path(volunteer_conn, :edit)
    assert html_response(conn, 403)
  end

  test "does not update chosen resource and redirects when data is valid for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    system_variable = insert(:system_variable)
    updated_params = [{system_variable.id, %{"key" => system_variable.key, "value" => "new program name"}}]

    conn = put student_conn, setting_path(student_conn, :update), settings: updated_params
    assert html_response(conn, 403)

    conn = put teacher_conn, setting_path(teacher_conn, :update), setting: updated_params
    assert html_response(conn, 403)

    conn = put volunteer_conn, setting_path(volunteer_conn, :update), setting: updated_params
    assert html_response(conn, 403)
  end

  test "does not update chosen resource and renders errors when data is invalid for coordinator user", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    system_variable = insert(:system_variable)
    updated_params = [{system_variable.id, %{"key" => system_variable.key, "value" => ""}}]

    conn = put coordinator_conn, setting_path(coordinator_conn, :update), settings: updated_params
    assert html_response(conn, 200) =~ "Edit settings"
    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "updates chosen resource and redirects when data is valid for coordinator user", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    system_variable = insert(:system_variable)
    updating_value = "new program name"
    updated_params = [{system_variable.id, %{"key" => system_variable.key, "value" => updating_value}}]

    conn = put coordinator_conn, setting_path(coordinator_conn, :update), settings: updated_params
    assert redirected_to(conn) == setting_path(coordinator_conn, :show)
    assert Repo.get(SystemVariable, system_variable.id).value == updating_value
  end

  test "does not update chosen resource when is not editable", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    insert(:system_variable)
    system_variable = insert(:system_variable, %{editable: false})
    updating_value = "new program name"
    updated_params = [{system_variable.id, %{"key" => system_variable.key, "value" => updating_value}}]

    conn = put coordinator_conn, setting_path(coordinator_conn, :update), settings: updated_params

    assert html_response(conn, 403)
    refute Repo.get(SystemVariable, system_variable.id).value == updating_value
  end

  test "does not update chosen inexisting resource", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    updated_params = [{"-1", %{"key" => "random key", "value" => "random value"}}]

    conn = put coordinator_conn, setting_path(coordinator_conn, :update), settings: updated_params

    assert html_response(conn, 404)
  end
end
