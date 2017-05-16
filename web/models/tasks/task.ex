defmodule CoursePlanner.Tasks.Task do
  @moduledoc """
    Defines a task to be accomplished by volunteers or coordinators
  """
  use CoursePlanner.Web, :model

  @cast_params [:name, :start_time, :finish_time, :user_id]
  @required_params [:name, :start_time, :finish_time]

  schema "tasks" do
    field :name, :string
    field :start_time, :naive_datetime
    field :finish_time, :naive_datetime
    belongs_to :user, CoursePlanner.User

    field :pending_at, :naive_datetime
    field :accomplished_at, :naive_datetime
    field :deleted_at, :naive_datetime

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @cast_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:user)
  end
end
