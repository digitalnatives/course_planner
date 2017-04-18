defmodule CoursePlanner.CourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Course

  @valid_attrs %{name: "some content", weekday: "some content"}
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
