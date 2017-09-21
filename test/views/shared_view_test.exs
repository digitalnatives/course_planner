defmodule CoursePlanner.SharedViewTest do
  use CoursePlannerWeb.ConnCase, async: true

  alias CoursePlannerWeb.SharedView
  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  describe "path_exact_match/2" do

    @tag user_role: :coordinator
    test "when path matches", %{conn: conn} do
      assert SharedView.path_exact_match(conn, "/")
    end

    @tag user_role: :coordinator
    test "when path does not matches", %{conn: conn} do
      refute SharedView.path_exact_match(conn, "/random/path")
    end
  end
end
