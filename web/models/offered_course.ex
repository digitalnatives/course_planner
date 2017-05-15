defmodule CoursePlanner.OfferedCourse do
  @moduledoc """
  This is the Course offered in a given Term
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Course, Terms.Term}

  schema "offered_courses" do
    belongs_to :term, Term
    belongs_to :course, Course

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:term_id, :course_id])
    |> validate_required([:term_id, :course_id])
    |> assoc_constraint(:term)
    |> assoc_constraint(:course)
  end

  def add_to_term_changeset(course_id) do
    %__MODULE__{}
    |> cast(%{"course_id" => course_id}, [:course_id])
    |> validate_required([:course_id])
    |> assoc_constraint(:term)
    |> assoc_constraint(:course)
  end
end
