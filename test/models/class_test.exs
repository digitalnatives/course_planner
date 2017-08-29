defmodule CoursePlanner.ClassTest do
  use CoursePlannerWeb.ModelCase

  import CoursePlanner.Factory
  alias CoursePlanner.{Classes.Class, Repo}

  @valid_attrs %{offered_course_id: nil, date: Timex.now(), finishes_at: %{hour: 15, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}
  @class_before_term %{offered_course_id: nil, date: Timex.shift(Timex.now(), years: -2), finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}
  @class_after_term %{offered_course_id: nil, date: Timex.shift(Timex.now(), months: 2), finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}

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

  test "class can't be before term's start_date" do
    oc = insert(:offered_course)
    changeset = Class.changeset(%Class{}, %{@class_before_term | offered_course_id: oc.id})
    refute changeset.valid?
  end

  test "class can't be after term's end_date" do
    oc = insert(:offered_course)
    changeset = Class.changeset(%Class{}, %{@class_after_term | offered_course_id: oc.id})
    refute changeset.valid?
  end

  test "update class with invalid date" do
    oc = insert(:offered_course)
    {:ok, class} = Class.changeset(%Class{}, %{@valid_attrs | offered_course_id: oc.id}) |> Repo.insert()
    changeset = Class.changeset(class, %{date: Timex.shift(Timex.now(), months: 3)}, :update)
    refute changeset.valid?
    changeset = Class.changeset(class, %{date: Timex.now()}, :update)
    assert changeset.valid?
  end

  test "class can't be created on a holiday" do
    holiday = build(:holiday, date: %Ecto.Date{day: 1, month: 1, year: 2017})
    term = insert(:term, holidays: [holiday])
    course = insert(:course)
    oc = insert(:offered_course, term: term, course: course)
    changeset = Class.changeset(%Class{}, %{@valid_attrs | date: %{day: 1, month: 1, year: 2017}, offered_course_id: oc.id})
    refute changeset.valid?
  end
end
