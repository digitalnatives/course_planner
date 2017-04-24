defmodule CoursePlanner.TaskTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Task

  @valid_attrs %{due: %{day: 17, month: 4, year: 2010}, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Task.changeset(%Task{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Task.changeset(%Task{}, @invalid_attrs)
    refute changeset.valid?
  end
end
