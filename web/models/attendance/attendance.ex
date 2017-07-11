defmodule CoursePlanner.Attendance do
  @moduledoc """
  This module holds the model for the attendance table
  """
  use CoursePlanner.Web, :model
  alias CoursePlanner.Settings
  alias Ecto.Changeset

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
    |> validate_comment()
  end

  def validate_comment(%{valid?: true} = changeset) do
    comment = Changeset.get_field(changeset, :comment)

    if comment_valid?(comment) do
      changeset
    else
      Changeset.add_error(changeset, :comment,
                  "The Provided comment is not among the valid options")
    end
  end
  def validate_comment(changeset), do: changeset

  defp comment_valid?(comment) do
      case comment do
        nil -> true
        _   -> "ATTENDANCE_DESCRIPTORS"
               |> Settings.get_value()
               |> Enum.member?(comment)
      end
  end
end
