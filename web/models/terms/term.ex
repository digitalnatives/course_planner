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
    embeds_many :holidays, Holiday, on_replace: :delete

    has_many :offered_courses, OfferedCourse, on_replace: :delete
    has_many :courses, through: [:offered_courses, :course]

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :start_date, :end_date])
    |> validate_required([:name, :start_date, :end_date])
    |> cast_embed(:holidays)
    |> validate_date_range()
    |> validate_holiday_date()
  end

  defp validate_holiday_date(%{valid?: true, changes: %{holidays: holidays_changesets}} = changeset) do
    st = changeset |> Changeset.get_field(:start_date) |> Date.cast!
    en = changeset |> Changeset.get_field(:end_date) |> Date.cast!

    validated_changesets =
      holidays_changesets
      |> Enum.map(fn(holiday_changeset) ->
           hl = holiday_changeset.changes.date |> Date.cast!
           case {Date.compare(st, hl), Date.compare(en, hl)} do
             {:gt,   _} -> Changeset.add_error(holiday_changeset, :date,
                                         "This holiday is before term's beginning")
             {_  , :lt} -> Changeset.add_error(holiday_changeset, :date,
                                        "This holiday is after term's ending")
             {_, _} -> holiday_changeset
           end
         end)

    Changeset.put_embed(changeset, :holidays, validated_changesets)
  end
  defp validate_holiday_date(changeset), do: changeset

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
