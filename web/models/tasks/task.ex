defmodule CoursePlanner.Tasks.Task do
  @moduledoc """
    Defines a task to be accomplished by volunteers or coordinators
  """
  use CoursePlanner.Web, :model

  @cast_params [:name, :start_time, :finish_time, :description, :max_volunteer]
  @required_params [:name, :start_time, :finish_time]

  schema "tasks" do
    field :name, :string
    field :max_volunteer, :integer
    field :start_time, :naive_datetime
    field :finish_time, :naive_datetime
    field :description, :string
    many_to_many :users, CoursePlanner.User, join_through: "users_tasks"

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @cast_params)
    |> validate_required(@required_params)
  end
end
