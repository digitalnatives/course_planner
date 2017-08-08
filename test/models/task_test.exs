defmodule CoursePlanner.TaskTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Tasks.Task

  @valid_attrs %{name: "mahname", max_volunteers: 2, start_time: Timex.now(), finish_time: Timex.shift(Timex.now(), days: 2)}
  @invalid_attrs %{}

  describe "test basic model tests :" do
    test "changeset with valid attributes" do
      changeset = Task.changeset(%Task{}, @valid_attrs)

      assert changeset.valid?
    end

    test "changeset with no attributes" do
      changeset = Task.changeset(%Task{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "tests the validation of task time when" do
    test "changeset has no finish_time" do
      changeset = Task.changeset(%Task{}, Map.delete(@valid_attrs, :finish_time))

      refute changeset.valid?
    end

    test "changeset has no start_time" do
      changeset = Task.changeset(%Task{}, Map.delete(@valid_attrs, :start_time))

      refute changeset.valid?
    end

    test "changeset has start_time as nil" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: nil})

      refute changeset.valid?
    end

    test "changeset has finish_time as nil" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | finish_time: nil})

      refute changeset.valid?
    end

    test "changeset has finish_time in past" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: Timex.shift(Timex.now(), days: -2), finish_time: Timex.shift(Timex.now(), days: -1)})

      refute changeset.valid?
    end

    test "update changeset has finish_time in past" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: Timex.shift(Timex.now(), days: -2), finish_time: Timex.shift(Timex.now(), days: -1)}, :update)

      assert changeset.valid?
    end

    test "changeset has finish_time before start_time" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: Timex.shift(Timex.now(), days: 2), finish_time: Timex.now()})

      refute changeset.valid?
    end

    test "changeset has finish_time equal to start_time" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: Timex.shift(Timex.now(), days: 2), start_time: Timex.shift(Timex.now(), days: 2)})

      refute changeset.valid?
    end
  end

  describe "tests validation of max_volunteers field when" do
    test "it does not exist" do
      changeset = Task.changeset(%Task{}, Map.delete(@valid_attrs, :max_volunteers))

      refute changeset.valid?
    end

    test "it is not integer" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: "random"})

      refute changeset.valid?
    end

    test "it is zero" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 0})

      refute changeset.valid?
    end

    test "it is negative" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: -1})

      refute changeset.valid?
    end

    test "it is 1000" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 1_000})

      refute changeset.valid?
    end

    test "it is 999" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 999})

      assert changeset.valid?
    end

    test "it is a valid number" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 42})

      assert changeset.valid?
    end
  end
end
