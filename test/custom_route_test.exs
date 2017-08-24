defmodule CoursePlanner.CustomRouteTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlannerWeb.CustomRoute
  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    {:ok, user: build(role, %{id: 1})}
  end

  describe "user_show_path" do
    @tag user_role: :coordinator
    test "coordinator goes to coordinators show page", %{user: user} do
      assert CustomRoute.user_show_path(user) == "/coordinators/1"
    end

    @tag user_role: :teacher
    test "teacher goes to teachers show page", %{user: user} do
      assert CustomRoute.user_show_path(user) == "/teachers/1"
    end

    @tag user_role: :student
    test "student goes to students show page", %{user: user} do
      assert CustomRoute.user_show_path(user) == "/students/1"
    end

    @tag user_role: :volunteer
    test "volunteer goes to volunteers show page", %{user: user} do
      assert CustomRoute.user_show_path(user) == "/volunteers/1"
    end
  end

  describe "user_show_url" do
    @tag user_role: :coordinator
    test "coordinator goes to coordinators show page", %{user: user} do
      assert CustomRoute.user_show_url(user) == "http://localhost:4001/coordinators/1"
    end

    @tag user_role: :teacher
    test "teacher goes to teachers show page", %{user: user} do
      assert CustomRoute.user_show_url(user) == "http://localhost:4001/teachers/1"
    end

    @tag user_role: :student
    test "student goes to students show page", %{user: user} do
      assert CustomRoute.user_show_url(user) == "http://localhost:4001/students/1"
    end

    @tag user_role: :volunteer
    test "volunteer goes to volunteers show page", %{user: user} do
      assert CustomRoute.user_show_url(user) == "http://localhost:4001/volunteers/1"
    end
  end
end
