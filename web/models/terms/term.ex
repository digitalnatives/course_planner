defmodule CoursePlanner.Terms.Term do
  @moduledoc """
    Defines the Term, usually a semester, in which courses take place
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{OfferedCourse, Statuses, Terms.Holiday, Types.EntityStatus}
  alias Ecto.{Date, Changeset}

  schema "terms" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    embeds_many :holidays, Holiday, on_replace: :delete

    has_many :offered_courses, OfferedCourse, on_replace: :delete
    has_many :courses, through: [:offered_courses, :course]

    field :status, EntityStatus
    field :planned_at, :naive_datetime
    field :active_at, :naive_datetime
    field :frozen_at, :naive_datetime
    field :finished_at, :naive_datetime
    field :deleted_at, :naive_datetime

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :start_date, :end_date, :status])
    |> validate_required([:name, :start_date, :end_date, :status])
    |> cast_embed(:holidays)
    |> Statuses.update_status_timestamp(EntityStatus)
    |> validate_date_range()
  end

  defp validate_date_range(%{errors: []} = changeset) do
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
