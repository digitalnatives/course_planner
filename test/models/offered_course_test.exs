defmodule CoursePlanner.OfferedCourseTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Course, OfferedCourse}
  alias CoursePlanner.Terms.Term
  alias Ecto.Changeset

  test "changeset with valid attributes" do
    changeset =
      OfferedCourse.changeset(
        %OfferedCourse{},
        %{term_id: new_term().id, course_id: new_course().id}
      )
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OfferedCourse.changeset(%OfferedCourse{}, %{})
    refute changeset.valid?
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
        session_duration: Ecto.Time.cast!("01:00:00"),
        status: "Active"
      })
  end
end
