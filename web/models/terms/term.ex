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
    |> validate_changes()
  end

  defp validate_changes(%{data: %{start_date: start_date, end_date: end_date},
      changes: changes, errors: []} = changeset) do
    {:ok, st} = Date.cast(Map.get(changes, :start_date) || start_date)
    {:ok, en} = Date.cast(Map.get(changes, :end_date) || end_date)
    case Date.compare(st, en) do
      :lt -> changeset
      :eq -> Changeset.add_error(changeset, :start_date, "Start date can't be the same than end date.")
      :gt -> Changeset.add_error(changeset, :start_date, "Start date can't be later than end date.")
    end
  end
  defp validate_changes(changeset), do: changeset
end
