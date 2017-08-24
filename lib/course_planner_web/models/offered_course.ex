defmodule CoursePlanner.OfferedCourse do
  @moduledoc """
  This is the Course offered in a given Term
  """
  use CoursePlannerWeb, :model

  alias CoursePlanner.{Course, Terms.Term, User, Class}

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

    field :number_of_sessions, :integer
    field :syllabus, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    target_params =
      [
        :term_id,
        :course_id,
        :number_of_sessions,
        :syllabus
      ]

    struct
    |> cast(params, target_params)
    |> validate_required(target_params)
    |> validate_number(:number_of_sessions, greater_than: 0, less_than: 100_000_000)
    |> assoc_constraint(:term)
    |> assoc_constraint(:course)
    |> unique_constraint(:course_id, name: :offered_courses_term_id_course_id_index,
                         message: "This course is already offered in this term")
  end
end
