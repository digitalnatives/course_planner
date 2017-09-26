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

  describe "class_list" do

    @tag user_role: :coordinator
    test "when class list is not empty", %{conn: _conn} do
      class = insert(:class, date: Timex.shift(Timex.now(), years: -2), finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0})
      result = SharedView.class_list([class])
      assert Phoenix.HTML.safe_to_string(result) =~ to_string(class.date)
      refute Phoenix.HTML.safe_to_string(result) =~ to_string(class.starting_at)
      refute Phoenix.HTML.safe_to_string(result) =~ to_string(class.finishes_at)
    end

    @tag user_role: :coordinator
    test "when class list is empty", %{conn: _conn} do
      result = SharedView.class_list([])
      assert Phoenix.HTML.safe_to_string(result) =~ "\n  <div class=\"class-list\">\n  </div>"
    end
  end
end
