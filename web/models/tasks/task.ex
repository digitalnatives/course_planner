defmodule CoursePlanner.Tasks.Task do
  @moduledoc """
    Defines a task to be accomplished by volunteers or coordinators
  """
  use CoursePlanner.Web, :model
  import Ecto.Changeset, except: [put_assoc: 3]
  alias CoursePlanner.User
  alias Ecto.Changeset

  @cast_params [:name, :start_time, :finish_time, :description, :max_volunteers]
  @required_params [:name, :start_time, :finish_time, :max_volunteers]

  schema "tasks" do
    field :name, :string
    field :max_volunteers, :integer
    field :start_time, :naive_datetime
    field :finish_time, :naive_datetime
    field :description, :string
    many_to_many :volunteers, User,
      join_through: "tasks_users",
      join_keys: [task_id: :id, user_id: :id],
      on_replace: :delete

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @cast_params)
    |> validate_required(@required_params)
    |> validate_datetime()
    |> validate_number(:max_volunteers, greater_than: 0, less_than: 1_000)
  end

  def put_assoc(changeset, field, field_data), do: Changeset.put_assoc(changeset, field, field_data)
  def put_assoc(changeset, field, field_data, :limit_max_volunteers) do
    changeset
    |> put_assoc(field, field_data)
    |> validate_volunteers_limit()
  end

  defp validate_volunteers_limit(%{valid?: true} = changeset) do
    max_number_of_volunteers = changeset |> Changeset.get_field(:max_volunteers)
    number_of_volunteers =
      changeset
      |> Changeset.get_field(:volunteers)
      |> length

    if number_of_volunteers > max_number_of_volunteers do
      add_error(changeset, :max_volunteers,
        "The maximum number of volunteers needed for this task is reached")
    else
      changeset
    end
  end
  defp validate_volunteers_limit(changeset), do: changeset

  defp validate_datetime(%{valid?: true} = changeset) do
    finish_time = Changeset.get_field(changeset, :finish_time)
    start_time = Changeset.get_field(changeset, :start_time)
    now = Timex.now()

    cond do
      Timex.compare(finish_time, start_time) != 1 -> add_error(changeset, :finish_time,
              "Finish time should be after the start time")

      Timex.compare(finish_time, now) != 1 -> add_error(changeset, :finish_time,
              "Finish time is already past")

      true -> changeset
    end
  end
  defp validate_datetime(changeset), do: changeset
end
