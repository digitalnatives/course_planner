defmodule CoursePlanner.ClassTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Class
  import CoursePlanner.Factory

  @valid_attrs %{offered_course_id: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    created_course = insert(:offered_course)
    changeset = Class.changeset(%Class{}, %{@valid_attrs | offered_course_id: created_course.id})
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = Class.changeset(%Class{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with no offered_course_id" do
    changeset = Class.changeset(%Class{}, @valid_attrs)
    refute changeset.valid?
  end
end
