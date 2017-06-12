defmodule CoursePlanner.Course do
  @moduledoc """
  This module holds the model for the course table
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.OfferedCourse

  schema "courses" do
    field :name, :string
    field :description, :string
    field :number_of_sessions, :integer
    field :session_duration, Ecto.Time
    field :syllabus, :string

    has_many :offered_courses, OfferedCourse, on_replace: :delete, on_delete: :delete_all
    has_many :terms, through: [:offered_courses, :term]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    target_params =
      [
        :name,
        :description,
        :number_of_sessions,
        :session_duration,
        :syllabus
      ]

    struct
    |> cast(params, target_params)
    |> validate_required([:name, :description, :number_of_sessions, :session_duration])
    |> validate_number(:number_of_sessions, greater_than: 0, less_than: 100_000_000)
  end

  def changeset(struct, params, :create) do
    struct
    |> changeset(params)
  end
end
