defmodule CoursePlanner.Tasks.Task do
  @moduledoc """
    Defines a task to be accomplished by volunteers or coordinators
  """
  use CoursePlanner.Web, :model

  @cast_params [:name, :start_time, :finish_time, :user_id, :description]
  @required_params [:name, :start_time, :finish_time]

  schema "tasks" do
    field :name, :string
    field :start_time, :naive_datetime
    field :finish_time, :naive_datetime
    field :description, :string
    belongs_to :user, CoursePlanner.User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @cast_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:user)
  end
end
