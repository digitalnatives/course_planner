defmodule CoursePlanner.PageControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.User

  setup do
    user =
      %User{
        name: "Test User",
        email: "testuser@example.com",
        password: "secret",
        password_confirmation: "secret"
      }

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
