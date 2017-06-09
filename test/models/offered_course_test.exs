defmodule CoursePlanner.OfferedCourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, Terms.Term}

  test "changeset with valid attributes" do
    changeset =
      OfferedCourse.changeset(
        %OfferedCourse{},
        %{term_id: new_term().id, course_id: new_course().id}
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
      OfferedCourse.changeset(%OfferedCourse{}, %{course_id: new_course().id, term_id: -1})
      |> Repo.insert

    refute changeset.valid?
    assert changeset.errors[:term] == {"does not exist", []}
  end

  test "changeset with nonexistent course" do
    {:error, changeset} =
      OfferedCourse.changeset(%OfferedCourse{}, %{course_id: -1, term_id: new_term().id})
      |> Repo.insert

    refute changeset.valid?
    assert changeset.errors[:course] == {"does not exist", []}
  end

  defp new_term do
    Repo.insert!(
      %Term{
        name: "Fall",
        start_date: %Ecto.Date{day: 1, month: 1, year: 2017},
        end_date: %Ecto.Date{day: 1, month: 6, year: 2017},
        status: "Planned"
      })
  end

  defp new_course do
    Repo.insert!(
      %Course{
        name: "Course",
        description: "Description",
        number_of_sessions: 1,
        session_duration: Ecto.Time.cast!("01:00:00")
      })
  end
end
