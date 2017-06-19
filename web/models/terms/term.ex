defmodule CoursePlanner.Terms.Term do
  @moduledoc """
    Defines the Term, usually a semester, in which courses take place
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{OfferedCourse, Terms.Holiday}
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
    st = Changeset.get_field(changeset, :start_date)
    en = Changeset.get_field(changeset, :end_date)
    min = Changeset.get_field(changeset, :minimum_teaching_days)
    number_of_holidays = length(holidays)
    if Timex.diff(en, st, :days) + 1 - number_of_holidays > min do
      changeset
    else
      Changeset.add_error(changeset, :minimum_teaching_days, "There's not enough minimum teaching days.")
    end
  end
  def validate_minimum_teaching_days(changeset, _holidays), do: changeset

  defp validate_date_range(%{valid?: true} = changeset) do
    st = changeset |> Changeset.get_field(:start_date) |> Date.cast!
    en = changeset |> Changeset.get_field(:end_date) |> Date.cast!
    case Date.compare(st, en) do
      :lt -> changeset
      :eq -> Changeset.add_error(changeset, :start_date, "Start date can't be the same than end date.")
      :gt -> Changeset.add_error(changeset, :start_date, "Start date can't be later than end date.")
    end
  end
  defp validate_date_range(changeset), do: changeset

end
