defmodule CoursePlannerWeb.EventControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  @create_attrs %{date: ~D[2010-04-17], description: "some description", finishing_time: ~T[15:00:00.000000], location: "some location", name: "some name", starting_time: ~T[14:00:00.000000]}
  @update_attrs %{date: ~D[2011-05-18], description: "some updated description", finishing_time: ~T[15:01:01.000000], location: "some updated location", name: "some updated name", starting_time: ~T[14:01:01.000000]}
  @invalid_attrs %{date: nil, description: nil, finishing_time: nil, location: nil, name: nil, starting_time: nil}

  setup(%{user_role: role}) do
    conn =
      role
      |> insert()
      |> guardian_login_html()

    event = insert(:event)

    {:ok, conn: conn, event: event}
  end

  describe "index" do
    @tag user_role: :student
    test "student can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end

    @tag user_role: :teacher
    test "teacher can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end

    @tag user_role: :volunteer
    test "volunteer can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end

    @tag user_role: :coordinator
    test "coordinator can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end
  end

  describe "new event" do
    @tag user_role: :student
    test "student cannot add new event", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "teacher cannot add new event", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "volunteer cannot add new event", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      html_response(conn, 403)
    end

    @tag user_role: :coordinator
    test "renders form", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "create event" do
    @tag user_role: :student
    test "student cannot create event", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "teacher cannot create event", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      html_response(conn, 403)
    end


    @tag user_role: :volunteer
    test "volunteer cannot create event", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      html_response(conn, 403)
    end

    @tag user_role: :coordinator
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == event_path(conn, :show, id)

      conn = get conn, event_path(conn, :show, id)
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    @tag user_role: :coordinator
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_attrs
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "edit event" do
    @tag user_role: :student
    test "student cannot edit event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "teacher cannot edit event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "volunteer cannot edit event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      html_response(conn, 403)
    end

    @tag user_role: :coordinator
    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      assert html_response(conn, 200) =~ event.name
    end
  end

  describe "update event" do
    @tag user_role: :student
    test "student cannot update event", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "teacher cannot update event", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "volunteer cannot update event", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      html_response(conn, 403)
    end

    @tag user_role: :coordinator
    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      assert redirected_to(conn) == event_path(conn, :show, event)

      conn = get conn, event_path(conn, :show, event)
      assert html_response(conn, 200) =~ @update_attrs.name
    end

    @tag user_role: :coordinator
    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @invalid_attrs
      assert html_response(conn, 200) =~ event.name
    end
  end

  describe "delete event" do
    @tag user_role: :student
    test "student cannot delete event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      response(conn, 403)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 200) =~ event.name
    end

    @tag user_role: :teacher
    test "teacher cannot delete event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      response(conn, 403)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 200) =~ event.name
    end

    @tag user_role: :volunteer
    test "volunteer cannot delete event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      response(conn, 403)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 200) =~ event.name
    end

    @tag user_role: :coordinator
    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      assert redirected_to(conn) == event_path(conn, :index)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 404)
    end
  end

end
