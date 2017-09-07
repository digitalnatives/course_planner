defmodule CoursePlanner.Classes.Class do
  @moduledoc """
  This module holds the model for the class table
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias CoursePlanner.{Repo, Courses.OfferedCourse, Attendances.Attendance, Classes}
  alias Ecto.{Time, Date, Changeset}

  schema "classes" do
    field :date, Date
    field :starting_at, Time
    field :finishes_at, Time
    field :classroom, :string
    belongs_to :offered_course, OfferedCourse
    has_many :attendances, Attendance, on_delete: :delete_all
    has_many :students, through: [:offered_course, :students]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    cast_params =
      [:offered_course_id, :date, :starting_at, :finishes_at, :classroom]

    struct
    |> cast(params, cast_params)
    |> validate_required([:offered_course_id, :date, :starting_at, :finishes_at])
    |> validate_date()
    |> Classes.validate_for_holiday()
  end

  def changeset(struct, params, :create) do
    struct
    |> changeset(params)
    |> validate_offered_course()
    |> validate_duration()
  end

  def changeset(struct, params, :update) do
    struct
    |> changeset(params)
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

  def validate_offered_course(%{changes: changes, valid?: true} = changeset) do
    offered_course_id = Map.get(changes, :offered_course_id)

    query = from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      join: s in assoc(oc, :students),
      preload: [teachers: t, students: s],
      where: oc.id == ^offered_course_id

      case Repo.one(query) do
        nil -> add_error(changeset, :offered_course_id,
                 "Attached course should have at least one teacher and one student")
        _   -> changeset
      end
  end
  def validate_offered_course(changeset), do: changeset

  defp validate_date(%{valid?: true} = changeset) do
    term = OfferedCourse
    |> Repo.get(Changeset.get_field(changeset, :offered_course_id))
    |> Repo.preload([:term])
    |> Map.get(:term)

    st = term
    |> Map.get(:start_date)
    |> Date.cast!()

    en = term
    |> Map.get(:end_date)
    |> Date.cast!()

    date = Changeset.get_field(changeset, :date)

    case {Date.compare(st, date), Date.compare(en, date)} do
      {:gt, _} -> Changeset.add_error(changeset, :date,
                  "The date can't be before the term's beginning")
      {_, :lt} -> Changeset.add_error(changeset, :date,
                  "The date can't be after the term's end")
      {_, _} -> changeset
    end
  end
  defp validate_date(changeset), do: changeset
end
