defmodule CoursePlanner.BulkControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory
  @valid_single_record %{"input" => %{"csv_data" => "Aname,AFamile,Anickname,A@a.com,student", "target" => "user", "title" => "user bulk creation"}}

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  @moduletag user_role: :student
  describe "settings functionality for student user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      html_response(conn, 403)
    end

    test "does not create bulk request for student user", %{conn: conn} do
      conn = post conn, bulk_path(conn, :create, @valid_single_record)
      html_response(conn, 403)
    end
  end

  @moduletag user_role: :teacher
  describe "settings functionality for teacher user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      html_response(conn, 403)
    end

    test "does not create bulk request for teacher user", %{conn: conn} do
      conn = post conn, bulk_path(conn, :create, @valid_single_record)
      html_response(conn, 403)
    end
  end

  @moduletag user_role: :volunteer
  describe "settings functionality for volunteer user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      html_response(conn, 403)
    end

    test "does not create bulk request for volunteer user", %{conn: conn} do
      conn = post conn, bulk_path(conn, :create, @valid_single_record)
      html_response(conn, 403)
    end
  end

  @moduletag user_role: :coordinator
  describe "settings functionality for coordinator user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 200) =~ "Bulk Users"
    end
  end

end
