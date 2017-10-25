defmodule CoursePlannerWeb.EventControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  @create_attrs %{date: ~D[2010-04-17], description: "some description", finishing_time: ~T[15:00:00.000000], location: "some location", name: "some name", starting_time: ~T[14:00:00.000000]}
  @update_attrs %{date: ~D[2011-05-18], description: "some updated description", finishing_time: ~T[15:01:01.000000], location: "some updated location", name: "some updated name", starting_time: ~T[14:01:01.000000]}
  @invalid_attrs %{date: nil, description: nil, finishing_time: nil, location: nil, name: nil, starting_time: nil}

  setup(context) do
    conn = build_conn(context)

    insert(:system_variable, %{key: "TIMEZONE", value: "UTC", type: "timezone"})
    event = insert(:event)

    {:ok, conn: conn, event: event}
  end

  describe "index" do
    @tag user_role: :student, pipeline: :browser
    test "student can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end

    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "coordinator can lists all events", %{conn: conn} do
      conn = get conn, event_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end
  end

  @describetag pipeline: :browser
  describe "new event" do
    @tag user_role: :student, pipeline: :browser
    test "student cannot add new event", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      html_response(conn, 403)
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher cannot add new event", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      html_response(conn, 403)
    end

    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer cannot add new event", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      html_response(conn, 403)
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "renders form", %{conn: conn} do
      conn = get conn, event_path(conn, :new)
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  @describetag pipeline: :browser
  describe "create event" do
    @tag user_role: :student, pipeline: :browser
    test "student cannot create event", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      html_response(conn, 403)
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher cannot create event", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      html_response(conn, 403)
    end


    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer cannot create event", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      html_response(conn, 403)
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == event_path(conn, :show, id)

      conn = get conn, event_path(conn, :show, id)
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_attrs
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  @describetag pipeline: :browser
  describe "edit event" do
    @tag user_role: :student, pipeline: :browser
    test "student cannot edit event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      html_response(conn, 403)
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher cannot edit event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      html_response(conn, 403)
    end

    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer cannot edit event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      html_response(conn, 403)
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :edit, event)
      assert html_response(conn, 200) =~ event.name
    end
  end

  @describetag pipeline: :browser
  describe "update event" do
    @tag user_role: :student, pipeline: :browser
    test "student cannot update event", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      html_response(conn, 403)
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher cannot update event", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      html_response(conn, 403)
    end

    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer cannot update event", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      html_response(conn, 403)
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "redirects when data is valid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      assert redirected_to(conn) == event_path(conn, :show, event)

      conn = get conn, event_path(conn, :show, event)
      assert html_response(conn, 200) =~ @update_attrs.name
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @invalid_attrs
      assert html_response(conn, 200) =~ event.name
    end
  end

  @describetag pipeline: :browser
  describe "delete event" do
    @tag user_role: :student, pipeline: :browser
    test "student cannot delete event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      response(conn, 403)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 200) =~ event.name
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher cannot delete event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      response(conn, 403)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 200) =~ event.name
    end

    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer cannot delete event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      response(conn, 403)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 200) =~ event.name
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      assert redirected_to(conn) == event_path(conn, :index)
      conn = get conn, event_path(conn, :show, event)
      response(conn, 404)
    end

    @tag user_role: :student, pipeline: :browser
    test "student cannot delete inexisting event", %{conn: conn} do
      conn = delete conn, event_path(conn, :delete, -1)
      response(conn, 403)
    end

    @tag user_role: :teacher, pipeline: :browser
    test "teacher cannot delete inexisting event", %{conn: conn} do
      conn = delete conn, event_path(conn, :delete, -1)
      response(conn, 403)
    end

    @tag user_role: :volunteer, pipeline: :browser
    test "volunteer cannot delete inexisting event", %{conn: conn} do
      conn = delete conn, event_path(conn, :delete, -1)
      response(conn, 403)
    end

    @tag user_role: :coordinator, pipeline: :browser
    test "inexisting event should give not found error", %{conn: conn} do
      conn = delete conn, event_path(conn, :delete, -1)
      response(conn, 404)
    end
  end

  describe "fetch events" do
    test "fails when unauthenticated user request to access the events", %{conn: conn} do
      conn = get conn, event_path(conn, :fetch)
      assert json_response(conn, 401)
    end

    @tag pipeline: :protected_api
    test "fails when my_events is not a boolean", %{conn: conn} do
      conn = get conn, event_path(conn, :fetch), %{date: "2017-01-01", my_events: "this is not a boolean"}
      assert json_response(conn, 406) == %{"errors" => %{"my_events" => "is invalid"}}
    end

    @tag pipeline: :protected_api
    test "fails when date is in wrong format", %{conn: conn} do
      conn = get conn, event_path(conn, :fetch), %{date: "2017-1-1", my_events: true}
      assert json_response(conn, 406) == %{"errors" => %{"date" => "is invalid"}}
    end

    @tag pipeline: :protected_api
    test "when there's none", %{conn: conn} do
      conn = get conn, event_path(conn, :fetch), %{date: "2017-01-01", my_events: true}
      assert json_response(conn, 200) == %{"events" => []}
    end

    @tag pipeline: :protected_api
    test "when there's many", %{conn: conn} do
      insert_list(3, :event, %{date: ~D[2017-01-03]})
      conn = get conn, event_path(conn, :fetch), %{date: "2017-01-04", my_events: true}
      assert %{"events" => events} = json_response(conn, 200)
      assert length(events) == 3
    end
  end

end
