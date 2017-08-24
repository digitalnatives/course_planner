defmodule CoursePlanner.Attendance do
  @moduledoc """
  This module holds the model for the attendance table
  """
  use CoursePlannerWeb, :model
  alias CoursePlanner.Settings

  schema "attendances" do
    field :attendance_type, :string
    field :comment, :string
    belongs_to :student, CoursePlanner.User
    belongs_to :class, CoursePlanner.Class

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:attendance_type, :class_id, :student_id, :comment])
    |> validate_required([:attendance_type, :class_id, :student_id])
    |> cast_assoc(:class)
    |> cast_assoc(:student)
    |> validate_inclusion(:comment, Settings.get_value("ATTENDANCE_DESCRIPTIONS"))
  end
end
