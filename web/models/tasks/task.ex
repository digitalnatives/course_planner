defmodule CoursePlanner.Tasks.Task do
  @moduledoc """
    Defines a task to be accomplished by volunteers or coordinators
  """
  use CoursePlanner.Web, :model
  alias CoursePlanner.User
  alias Ecto.Changeset

  @cast_params [:name, :start_time, :finish_time, :description, :max_volunteer]
  @required_params [:name, :start_time, :finish_time]

  schema "tasks" do
    field :name, :string
    field :max_volunteer, :integer
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
    |> validate_number(:max_volunteer, greater_than: 0, less_than: 1_000)
  end

  def put_assoc(changeset, field, field_data) do
    changeset
    |> Changeset.put_assoc(field, field_data)
    |> validate_volunteers_limit()
  end

  defp validate_volunteers_limit(%{valid?: true} = changeset) do
    max_number_of_volunteers = changeset |> Changeset.get_field(:max_volunteer)
    number_of_volunteers =
      changeset
      |> Changeset.get_field(:volunteers)
      |> length

    if number_of_volunteers > max_number_of_volunteers do
      add_error(changeset, :max_volunteer,
        "The maximum number of volunteers needed for this task is reached")
    else
      changeset
    end
  end
  defp validate_volunteers_limit(changeset), do: changeset

end
