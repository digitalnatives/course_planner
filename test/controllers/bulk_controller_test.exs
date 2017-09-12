defmodule CoursePlanner.BulkControllerTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlanner.{Repo, Accounts.User}

  import CoursePlanner.Factory

  @file_path "/tmp/csv_test.txt"

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  defp create_input_params(target, title, csv_data) do
    File.touch!(@file_path)
    File.write!(@file_path, csv_data)
    %{"input" => %{"csv_file" => %{"path" => "#{@file_path}"}, "target" => target, "title" => title}}
  end

  @moduletag user_role: :student
  describe "settings functionality for student user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 403)
    end

    test "does not create bulk request for student user", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 403)
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end

  @moduletag user_role: :teacher
  describe "settings functionality for teacher user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      html_response(conn, 403)
    end

    test "does not create bulk request for teacher user", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 403)
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end

  @moduletag user_role: :volunteer
  describe "settings functionality for volunteer user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 403)
    end

    test "does not create bulk request for volunteer user", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 403)
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end

  @moduletag user_role: :coordinator
  describe "settings functionality for coordinator user" do
    test "render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 200) =~ "Bulk Users"
    end

    @tag user_role: :coordinator
    test "creates bulk request", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert redirected_to(conn) == user_path(conn, :index)
      assert get_flash(conn, "info") == "All users are created and notified by."
      assert Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "does not create bulk request if input fields are not enough", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200) =~ "Input data in row #1 is not matching the column number."
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "does not create bulk request if role is unknown", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,unknown")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "role is invalid"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "does not create bulk request if email is already taken", %{conn: conn} do
      insert(:student, email: "a@a.com")
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "email has already been taken"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "returning error if no action is implemented for the requested target", %{conn: conn} do
      params = create_input_params("invalid target", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "Something went wrong."
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end
end
