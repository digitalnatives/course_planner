defmodule CoursePlanner.Class do
  @moduledoc """
  This module holds the model for the class table
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{OfferedCourse, Types, Attendance}
  alias Ecto.{Time, Date, DateTime}

  schema "classes" do
    field :date, Date
    field :starting_at, Time
    field :finishes_at, Time
    field :status, Types.EntityStatus
    field :deleted_at, DateTime
    field :classroom, :string
    belongs_to :offered_course, OfferedCourse
    has_many :attendances, Attendance
    has_many :students, through: [:offered_course, :students]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    cast_params =
      [:offered_course_id, :date, :starting_at, :finishes_at, :status, :deleted_at, :classroom]

    struct
    |> cast(params, cast_params)
    |> validate_required([:offered_course_id, :date, :starting_at, :finishes_at, :status])
  end

  def changeset(struct, _params, :fill) do
    struct
    |> cast_assoc(:attendances)
  end

  def changeset(struct, params, :create) do
    struct
    |> changeset(params)
    |> validate_inclusion(:status, ["Planned", "Active"])
    |> validate_duration()
  end

  def changeset(struct, params, :update) do
    struct
    |> changeset(params)
    |> validate_inclusion(:status, ["Planned", "Active"])
    |> validate_duration()
  end

  def validate_duration(%{changes: changes, valid?: true} = changeset) do
    starting_at = Map.get(changes, :starting_at) || Map.get(changeset.data, :starting_at)
    finishes_at = Map.get(changes, :finishes_at) || Map.get(changeset.data, :finishes_at)

    cond do
      Time.compare(starting_at, Time.from_erl({0, 0, 0})) == :eq ->
        add_error(changeset, :starting_at, "Starting time cannot be zero")

      Time.compare(finishes_at, Time.from_erl({0, 0, 0})) == :eq ->
        add_error(changeset, :finishes_at, "Finishing time cannot be zero")

      Time.compare(starting_at, finishes_at) != :lt ->
        add_error(changeset, :finishes_at,
          "Finishing time should be greater than the starting time")

      true -> changeset
    end
  end

  def validate_duration(changeset), do: changeset

end
