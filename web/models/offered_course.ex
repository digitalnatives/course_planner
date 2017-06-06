defmodule CoursePlanner.OfferedCourse do
  @moduledoc """
  This is the Course offered in a given Term
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Course, Terms.Term, User, Class, OfferedCourse}

  schema "offered_courses" do
    belongs_to :term, Term
    belongs_to :course, Course
    many_to_many :students, User,
      join_through: "offered_courses_students",
      join_keys: [offered_course_id: :id, student_id: :id],
      on_replace: :delete
    many_to_many :teachers, User,
      join_through: "offered_courses_teachers",
      join_keys: [offered_course_id: :id, teacher_id: :id],
      on_replace: :delete
    has_many :classes, Class, on_replace: :delete
    has_many :attendances, through: [:classes, :attendances]

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:term_id, :course_id])
    |> validate_required([:term_id, :course_id])
    |> assoc_constraint(:term)
    |> assoc_constraint(:course)
    |> validate_unique_course_term()
  end

  defp validate_unique_course_term(%{changes: changes, valid?: true} = changeset) do
    course_id = Map.get(changes, :course_id) || Map.get(changeset.data, :course_id)
    term_id = Map.get(changes, :term_id) || Map.get(changeset.data, :term_id)

    query = from oc in OfferedCourse,
      join: c in assoc(oc, :course),
      join: t in assoc(oc, :term),
      preload: [course: c, term: t],
      where: t.id == ^term_id and c.id == ^course_id

    case Repo.one(query) do
      nil -> changeset
      _   -> add_error(changeset, :course_id,
                       "This course is already offered in this term")
    end
  end
  defp validate_unique_course_term(changeset), do: changeset
end
