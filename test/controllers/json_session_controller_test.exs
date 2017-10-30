defmodule CoursePlanner.JsonSessionController do
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

  @moduletag user_role: nil
  describe "attempt login in" do
    test "returns error if password is wrong", %{conn: conn} do
      user = insert(:coordinator)
      login_params = %{email: user.email, password: "random password"}
      conn = post conn, json_session_path(conn, :create, login_params)
      assert json_response(conn, 200) == %{"token" => "error"}
    end

    test "returns error if username is wrong", %{conn: conn} do
      login_params = %{email: "random@example.com", password: "secret"}
      conn = post conn, json_session_path(conn, :create, login_params)
      assert json_response(conn, 200) == %{"token" => "error"}
    end

    test "returns valid token if username and password are correct", %{conn: conn} do
      user = insert(:coordinator)
      login_params = %{email: user.email, password: "secret"}
      conn = post conn, json_session_path(conn, :create, login_params)
      %{"token" => token} = json_response(conn, 200)
      refute token == "error"
    end

    test "returns error if format is not correct", %{conn: conn} do
      login_params = %{email: "random@example.com"}
      conn = post conn, json_session_path(conn, :create, login_params)
      assert json_response(conn, 406)
    end
  end
end
