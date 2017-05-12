defmodule CoursePlanner.OfferedCourse do
  @moduledoc """
  This is the Course offered in a given Term
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Course, Terms.Term, User}

  schema "offered_courses" do
    belongs_to :term, Term
    belongs_to :course, Course
    many_to_many :students, User,
      join_through: "offered_courses_students",
      join_keys: [offered_course_id: :id, student_id: :id],
      on_replace: :delete

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:term_id, :course_id])
    |> validate_required([:term_id, :course_id])
    |> assoc_constraint(:term)
    |> assoc_constraint(:course)
  end
end
