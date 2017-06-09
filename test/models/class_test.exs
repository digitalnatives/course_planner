defmodule CoursePlanner.ClassTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Class, Course, OfferedCourse, Repo, Terms}

  @term_attrs %{name: "Term", start_date: "2010-01-01", end_date: "2010-12-31", status: "Active"}
  @valid_course_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, status: "Planned", syllabus: "some content"}
  @valid_attrs %{offered_course_id: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}
  @class_before_term %{offered_course_id: nil, date: %{day: 17, month: 4, year: 2009}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}
  @class_after_term %{offered_course_id: nil, date: %{day: 17, month: 4, year: 2011}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}}

  defp create_course do
    {:ok, course} = %Course{} |> Course.changeset(@valid_course_attrs, :create) |> Repo.insert
    {:ok, term} = Terms.create(@term_attrs)
    %OfferedCourse{} |> OfferedCourse.changeset(%{course_id: course.id, term_id: term.id}) |> Repo.insert
  end

  test "changeset with valid attributes" do
    {:ok, created_course} = create_course()
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
    {:ok, oc} = create_course()
    changeset = Class.changeset(%Class{}, %{@class_before_term | offered_course_id: oc.id})
    refute changeset.valid?
  end

  test "class can't be after term's end_date" do
    {:ok, oc} = create_course()
    changeset = Class.changeset(%Class{}, %{@class_after_term | offered_course_id: oc.id})
    refute changeset.valid?
  end
end
