defmodule CoursePlanner.Class do
  @moduledoc """
  This module holds the model for the class table
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.Types, as: Types

  schema "classes" do
    field :class_date, Ecto.Date
    field :starting_at, Ecto.Time
    field :finishes_at, Ecto.Time
    field :status, Types.EntityStatus
    field :deleted_at, Ecto.DateTime
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
end
