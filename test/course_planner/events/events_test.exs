defmodule CoursePlanner.EventsTest do
  use CoursePlanner.DataCase

  alias CoursePlanner.Events
  import CoursePlanner.Factory

  describe "events" do
    alias CoursePlanner.Events.Event

    @valid_attrs %{date: ~D[2010-04-17], description: "some description", finishing_time: ~T[15:00:00.000000], location: "some location", name: "some name", starting_time: ~T[14:00:00.000000]}
    @update_attrs %{date: ~D[2011-05-18], description: "some updated description", finishing_time: ~T[15:01:01.000000], location: "some updated location", name: "some updated name", starting_time: ~T[14:01:01.000000]}
    @invalid_attrs %{date: nil, description: nil, finishing_time: nil, location: nil, name: nil, starting_time: nil}

    test "all/0 returns all events" do
      event = insert(:event)
      assert Events.all() == [event]
    end

    test "all_with_users/0 returns all events with preloaded users" do
      event = insert(:event)
      assert Events.all_with_users() == [event |> Repo.preload(:users)]
    end

    test "get/1 returns the event with given id" do
      event = insert(:event) |> Repo.preload(:users)
      assert Events.get(event.id) == {:ok, event}
    end

    test "create/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create(@valid_attrs)
      assert event.date == ~D[2010-04-17]
      assert event.description == "some description"
      assert event.finishing_time == ~T[15:00:00.000000]
      assert event.location == "some location"
      assert event.name == "some name"
      assert event.starting_time == ~T[14:00:00.000000]
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the event" do
      event = insert(:event)
      assert {:ok, event} = Events.update(event, @update_attrs)
      assert %Event{} = event
      assert event.date == ~D[2011-05-18]
      assert event.description == "some updated description"
      assert event.finishing_time == ~T[15:01:01.000000]
      assert event.location == "some updated location"
      assert event.name == "some updated name"
      assert event.starting_time == ~T[14:01:01.000000]
    end

    test "update/2 with invalid data returns error changeset" do
      event = insert(:event) |> Repo.preload(:users)
      assert {:error, %Ecto.Changeset{}} = Events.update(event, @invalid_attrs)
      assert {:ok, event} == Events.get(event.id)
    end

    test "delete/1 deletes the event" do
      event = insert(:event)
      assert {:ok, %Event{}} = Events.delete(event)
      assert Events.get(event.id) == {:error, :not_found}
    end

    test "change/1 returns a event changeset" do
      event = insert(:event)
      assert %Ecto.Changeset{} = Events.change(event)
    end

    test "greater starting_time should return error" do
      now = Timex.now()
      invalid_attrs =
        @valid_attrs
        |> Map.put(:starting_time, now)
        |> Map.put(:finishing_time, Timex.shift(now, hours: -1))

      assert {:error, %Ecto.Changeset{} = changeset} = Events.create(invalid_attrs)
      assert changeset.errors[:finishing_time] == {"finishing time should be greater than the starting time", []}
    end

    test "equal start and end time should return error" do
      now = Timex.now()
      invalid_attrs =
        @valid_attrs
        |> Map.put(:starting_time, now)
        |> Map.put(:finishing_time, now)

      assert {:error, %Ecto.Changeset{} = changeset} = Events.create(invalid_attrs)
      assert changeset.errors[:finishing_time] == {"finishing time should be greater than the starting time", []}
    end

    test "add users to events" do
      users = [insert(:coordinator).id, insert(:student).id, insert(:teacher).id, insert(:volunteer).id]
      event = insert(:event)

      {:ok, updated_event} = Events.update(event, %{"user_ids" => users})
      assert length(updated_event.users) == 4
    end

    test "remove users from events" do
      users = [insert(:coordinator), insert(:student), insert(:teacher), insert(:volunteer)]
      event = insert(:event, %{users: users})

      {:ok, updated_event} = Events.update(event, %{"user_ids" => []})
      assert length(updated_event.users) == 0
    end
  end

  describe "event encode" do
    test "encode event" do
      event = insert(:event)
      {:ok, encoded_event} = Poison.encode(event)
      assert encoded_event =~ "name"
      assert encoded_event =~ "location"
      assert encoded_event =~ "description"
      assert encoded_event =~ "date"
      assert encoded_event =~ "id"
      assert encoded_event =~ "starting_time"
      assert encoded_event =~ "finishing_time"
    end

    test "does not encode users" do
      users = [insert(:coordinator), insert(:student), insert(:teacher), insert(:volunteer)]
      event = insert(:event, %{users: users})
      {:ok, encoded_event} = Poison.encode(event)
      refute encoded_event =~ ~r/users/
    end
  end
end
