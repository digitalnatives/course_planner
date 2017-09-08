defmodule CoursePlanner.Terms.Term do
  @moduledoc """
    Defines the Term, usually a semester, in which courses take place
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias CoursePlanner.{Courses.OfferedCourse, Terms.Holiday}
  alias Ecto.{Date, Changeset}

  schema "terms" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :minimum_teaching_days, :integer
    embeds_many :holidays, Holiday, on_replace: :delete

    has_many :offered_courses, OfferedCourse, on_replace: :delete
    has_many :courses, through: [:offered_courses, :course]

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :start_date, :end_date, :minimum_teaching_days])
    |> validate_required([:name, :start_date, :end_date, :minimum_teaching_days])
    |> validate_date_range()
  end

  def validate_minimum_teaching_days(%{valid?: true} = changeset, holidays) do
    teaching_days = count_teaching_days(changeset, holidays)
    min = Changeset.get_field(changeset, :minimum_teaching_days)
    if teaching_days > min do
      changeset
    else
      Changeset.add_error(
        changeset,
        :minimum_teaching_days,
        "There's not enough minimum teaching days.")
    end
  end
  def validate_minimum_teaching_days(changeset, _holidays), do: changeset

  defp count_teaching_days(changeset, holidays) do
    Timex.diff(
      Changeset.get_field(changeset, :end_date),
      Changeset.get_field(changeset, :start_date),
      :days) + 1 - length(holidays)
  end

  defp validate_date_range(%{valid?: true} = changeset) do
    st = changeset |> Changeset.get_field(:start_date) |> Date.cast!
    en = changeset |> Changeset.get_field(:end_date) |> Date.cast!
    case Date.compare(st, en) do
      :lt -> changeset
      :eq -> Changeset.add_error(changeset, :start_date, "can't be the same than end date.")
      :gt -> Changeset.add_error(changeset, :start_date, "can't be later than end date.")
    end
  end
  defp validate_date_range(changeset), do: changeset

end
