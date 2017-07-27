defmodule CoursePlanner.TaskTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Tasks.Task

  @valid_attrs %{name: "mahname", max_volunteers: 2, start_time: Timex.now(), finish_time: Timex.shift(Timex.now(), days: 2)}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Task.changeset(%Task{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = Task.changeset(%Task{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with no start_time" do
    changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: nil})

    refute changeset.valid?
  end

  test "changeset with no finish_time" do
    changeset = Task.changeset(%Task{}, %{@valid_attrs | finish_time: nil})

    refute changeset.valid?
  end

  test "changeset with finish_time in past" do
    changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: Timex.shift(Timex.now(), days: -2), finish_time: Timex.shift(Timex.now(), days: -1)})

    refute changeset.valid?
  end

  test "changeset with finish_time before start_time" do
    changeset = Task.changeset(%Task{}, %{@valid_attrs | start_time: Timex.shift(Timex.now(), days: 2), finish_time: Timex.now()})

    refute changeset.valid?
  end

  describe "tests max_volunteers" do
    test "when it is zero" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 0})

      refute changeset.valid?
    end

    test "when it is negative" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: -1})

      refute changeset.valid?
    end

    test "when it is 1000" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 1_000})

      refute changeset.valid?
    end

    test "when it is 999" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 999})

      assert changeset.valid?
    end

    test "when it is a valid number" do
      changeset = Task.changeset(%Task{}, %{@valid_attrs | max_volunteers: 42})

      assert changeset.valid?
    end
  end
end
