defmodule CoursePlanner.OfferedCourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, Terms.Term}

  test "changeset with valid attributes" do
    changeset =
      OfferedCourse.changeset(
        %OfferedCourse{},
        %{term_id: new_term().id, course_id: new_course().id, number_of_sessions: 2, syllabus: "some content"}
      )

    assert changeset.valid?
  end

  test "changeset without required associations" do
    changeset = OfferedCourse.changeset(%OfferedCourse{}, %{})

    refute changeset.valid?
    assert changeset.errors[:term_id]   == {"can't be blank", [validation: :required]}
    assert changeset.errors[:course_id] == {"can't be blank", [validation: :required]}
  end

  test "changeset with nonexistent term" do
    {:error, changeset} =
      OfferedCourse.changeset(%OfferedCourse{}, %{course_id: new_course().id, term_id: -1, number_of_sessions: 42, syllabus: "some content"})
      |> Repo.insert

    refute changeset.valid?
    assert changeset.errors[:term] == {"does not exist", []}
  end

  test "changeset with nonexistent course" do
    {:error, changeset} =
      OfferedCourse.changeset(%OfferedCourse{}, %{course_id: -1, term_id: new_term().id, number_of_sessions: 42, syllabus: "some content"})
      |> Repo.insert

    refute changeset.valid?
    assert changeset.errors[:course] == {"does not exist", []}
  end

  test "changeset with number_of_sessions equal zero" do
    changeset = OfferedCourse.changeset(%OfferedCourse{}, %{course_id: -1, term_id: new_term().id, number_of_sessions: 0, syllabus: "some content"})
    refute changeset.valid?
  end

  test "changeset with negative number_of_sessions" do
    changeset = OfferedCourse.changeset(%OfferedCourse{}, %{course_id: -1, term_id: new_term().id, number_of_sessions: -1, syllabus: "some content"})
    refute changeset.valid?
  end

  test "changeset with too big number_of_sessions" do
    changeset = OfferedCourse.changeset(%OfferedCourse{}, %{course_id: -1, term_id: new_term().id, number_of_sessions: 100_000_000, syllabus: "some content"})
    refute changeset.valid?
  end

  defp new_term do
    Repo.insert!(
      %Term{
        name: "Fall",
        start_date: %Ecto.Date{day: 1, month: 1, year: 2017},
        end_date: %Ecto.Date{day: 1, month: 6, year: 2017}
      })
  end

  defp new_course do
    Repo.insert!(
      %Course{
        name: "Course",
        description: "Description"
      })
  end
end
