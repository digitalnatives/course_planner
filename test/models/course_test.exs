defmodule CoursePlanner.CourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Course

  @valid_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, status: "some content", syllabus: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Course.changeset(%Course{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Course.changeset(%Course{}, @invalid_attrs)
    refute changeset.valid?
  end
end
