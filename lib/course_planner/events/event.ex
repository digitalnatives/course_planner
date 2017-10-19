defmodule CoursePlanner.Events.Event do
  @moduledoc """
  Event schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias CoursePlanner.Accounts.User

  schema "events" do
    field :name, :string
    field :description, :string
    field :location, :string

    field :date, :date
    field :starting_time, :time
    field :finishing_time, :time

    many_to_many :users, User, join_through: "events_users"

    timestamps()
  end

  def changeset(%__MODULE__{} = event, attrs) do
    event
    |> cast(attrs, [:name, :description, :date, :starting_time, :finishing_time, :location])
    |> validate_required([:name, :description, :date, :starting_time, :finishing_time, :location])
    |> validate_duration()
  end

  def validate_duration(%{valid?: true} = changeset) do
    starting_time = get_field(changeset, :starting_time)
    finishing_time = get_field(changeset, :finishing_time)

    if Timex.diff(finishing_time, starting_time) <= 0 do
      add_error(changeset, :finishing_time,
          "finishing time should be greater than the starting time")
    else
      changeset
    end
  end
  def validate_duration(changeset), do: changeset

end
