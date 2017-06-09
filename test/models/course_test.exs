defmodule CoursePlanner.CourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Course, as: Course

  @valid_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, syllabus: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Course.changeset(%Course{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Course.changeset(%Course{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with number_of_sessions equal zero" do
    changeset = Course.changeset(%Course{}, %{ @valid_attrs | number_of_sessions: 0 })
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
end
