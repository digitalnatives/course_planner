defmodule CoursePlanner.PasswordControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup(param) do
    conn =
      case param do
        %{user_role: nil} -> Phoenix.ConnTest.build_conn()
        %{user_role: role} -> login_as(role)
      end

    {:ok, conn: conn}
  end

  defp login_as(role) do
    role
    |> insert()
    |> guardian_login_html()
  end


  describe "rendering of password reset page" do
    @moduletag user_role: :nil
    test "password reset page is loaded for a not logged in request", %{conn: conn} do
      conn = get conn, password_path(conn, :new)
      assert html_response(conn, 200)
    end

    @moduletag user_role: :coordinator
    test "password reset page is loaded for a logged in request", %{conn: conn} do
      conn = get conn, password_path(conn, :new)
      assert html_response(conn, 200)
    end
  end
end
