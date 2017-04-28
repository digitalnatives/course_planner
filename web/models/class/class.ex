defmodule CoursePlanner.Class do
  @moduledoc """
  This module holds the model for the class table
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.Types, as: Types
  alias Ecto.{Time, Date, DateTime}

  schema "classes" do
    field :class_date, Date
    field :starting_at, Time
    field :finishes_at, Time
    field :status, Types.EntityStatus
    field :deleted_at, DateTime
    belongs_to :course, CoursePlanner.Course

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:course_id, :class_date, :starting_at, :finishes_at, :status, :deleted_at])
    |> validate_required([:course_id, :class_date, :starting_at, :finishes_at, :status])
  end

  def changeset(struct, params, :create) do
    struct
    |> changeset(params)
    |> validate_inclusion(:status, ["Planned", "Active"])
    |> validate_duration()
  end

  def validate_duration(%{changes: changes, valid?: true} = changeset) do
    cond do
      Time.compare(changes.starting_at, Time.from_erl({0, 0, 0})) == :eq ->
        add_error(changeset, :starting_at, "Starting time cannot be zero")

      Time.compare(changes.starting_at, Time.from_erl({0, 0, 0})) == :eq ->
        add_error(changeset, :finishes_at, "Finishing time cannot be zero")

      Time.compare(changes.starting_at, changes.finishes_at) != :lt ->
        add_error(changeset, :finishes_at,
          "Finishing time should be greater than the starting time")

      true -> changeset
    end
  end
  def validate_duration(changeset), do: changeset

end
