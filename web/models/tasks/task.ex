defmodule CoursePlanner.Tasks.Task do
  @moduledoc """
    Defines a task to be accomplished by volunteers or coordinators
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.Tasks.TaskStatus
  alias CoursePlanner.Statuses

  @target_params [:name, :deadline, :status]

  schema "tasks" do
    field :name, :string
    field :deadline, :date
    field :status, TaskStatus
    belongs_to :user, CoursePlanner.User

    field :pending_at, :naive_datetime
    field :accomplished_at, :naive_datetime
    field :deleted_at, :naive_datetime

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @target_params)
    # |> cast_assoc(:user)
    |> validate_required(@target_params)
    |> Statuses.update_status_timestamp(TaskStatus)
  end
end