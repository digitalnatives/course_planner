defmodule CoursePlanner.SettingControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Setting
  import CoursePlanner.Factory

  @valid_attrs %{notification_frequency: "20", program_address: "some address", program_description: "some description", program_email_address: "some email address", program_name: "some name", program_phone_number: "some phone number"}

  setup do
    changeset = Setting.changeset(%Setting{}, @valid_attrs)
    setting = Repo.insert!(changeset)
    {:ok, setting: setting}
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "shows chosen resource only for coordinator", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    conn = get coordinator_conn, setting_path(coordinator_conn, :show)
    assert html_response(conn, 200) =~ "Show setting"
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
    assert html_response(conn, 200) =~ "Edit setting"
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

  test "updates chosen resource and redirects when data is valid for coordinator user", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    updated_params = %{@valid_attrs | notification_frequency: 10, program_description: "new description"}
    conn = put coordinator_conn, setting_path(coordinator_conn, :update), setting: updated_params
    assert redirected_to(conn) == setting_path(coordinator_conn, :show)
    assert Repo.get_by(Setting, updated_params)
  end

  test "does not update chosen resource and renders errors when data is invalid for coordinator user", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    updated_params = %{@valid_attrs | notification_frequency: 0, program_description: ""}
    conn = put coordinator_conn, setting_path(coordinator_conn, :update), setting: updated_params
    assert html_response(conn, 200) =~ "Edit setting"
  end

  test "does not update chosen resource and redirects when data is valid for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    updated_params = %{@valid_attrs | notification_frequency: 10, program_description: "new description"}

    conn = put student_conn, setting_path(student_conn, :update), setting: updated_params
    assert html_response(conn, 403)

    conn = put teacher_conn, setting_path(teacher_conn, :update), setting: updated_params
    assert html_response(conn, 403)

    conn = put volunteer_conn, setting_path(volunteer_conn, :update), setting: updated_params
    assert html_response(conn, 403)
  end
end
