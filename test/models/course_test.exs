defmodule CoursePlanner.CourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Course

  @valid_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, status: "Planned", syllabus: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Course.changeset(%Course{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Course.changeset(%Course{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with negative number_of_sessions" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | number_of_sessions: -1 })
    refute changeset.valid?
  end

  test "changeset with too big number_of_sessions" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | number_of_sessions: 100_000_000 })
    refute changeset.valid?
  end

  test "changeset with invalid status" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "random" })
    refute changeset.valid?
  end

  test "changeset with status Planned" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "Planned" })
    assert changeset.valid?
  end

  test "changeset with status Active" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "Active" })
    assert changeset.valid?
  end

  test "changeset with status Finished" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "Finished" })
    assert changeset.valid?
  end

  test "changeset with status Graduated" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "Graduated" })
    assert changeset.valid?
  end

  test "changeset with status Frozen" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "Frozen" })
    assert changeset.valid?
  end

  test "changeset with status Deleted" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | status: "Deleted" })
    assert changeset.valid?
  end
end
