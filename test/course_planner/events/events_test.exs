defmodule CoursePlanner.EventsTest do
  use CoursePlanner.DataCase

  alias CoursePlanner.Events

  describe "events" do
    alias CoursePlanner.Events.Event

    @valid_attrs %{date: ~D[2010-04-17], description: "some description", finishing_time: ~T[14:00:00.000000], location: "some location", name: "some name", starting_time: ~T[14:00:00.000000]}
    @update_attrs %{date: ~D[2011-05-18], description: "some updated description", finishing_time: ~T[15:01:01.000000], location: "some updated location", name: "some updated name", starting_time: ~T[15:01:01.000000]}
    @invalid_attrs %{date: nil, description: nil, finishing_time: nil, location: nil, name: nil, starting_time: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.all() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get(event.id) == {:ok, event}
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create(@valid_attrs)
      assert event.date == ~D[2010-04-17]
      assert event.description == "some description"
      assert event.finishing_time == ~T[14:00:00.000000]
      assert event.location == "some location"
      assert event.name == "some name"
      assert event.starting_time == ~T[14:00:00.000000]
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, event} = Events.update(event, @update_attrs)
      assert %Event{} = event
      assert event.date == ~D[2011-05-18]
      assert event.description == "some updated description"
      assert event.finishing_time == ~T[15:01:01.000000]
      assert event.location == "some updated location"
      assert event.name == "some updated name"
      assert event.starting_time == ~T[15:01:01.000000]
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update(event, @invalid_attrs)
      assert {:ok, event} == Events.get(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete(event)
      assert Events.get(event.id) == {:error, :not_found}
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change(event)
    end
  end
end
