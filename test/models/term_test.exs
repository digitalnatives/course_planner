defmodule CoursePlanner.TermTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Term

  @valid_attrs %{deleted_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, finished_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, finishing_day: %{day: 17, month: 4, year: 2010}, frozen_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, holidays: [], name: "some content", starting_day: %{day: 17, month: 4, year: 2010}, status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Term.changeset(%Term{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Term.changeset(%Term{}, @invalid_attrs)
    refute changeset.valid?
  end
end
