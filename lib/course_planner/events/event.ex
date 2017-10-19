defmodule CoursePlanner.Events.Event do
  @moduledoc """
  Event schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias CoursePlanner.Accounts.User


  schema "events" do
    field :date, :date
    field :description, :string
    field :finishing_time, :time
    field :location, :string
    field :name, :string
    field :starting_time, :time
    many_to_many :users, User, join_through: "events_users"

    timestamps()
  end

  def changeset(%__MODULE__{} = event, attrs) do
    event
    |> cast(attrs, [:name, :description, :date, :starting_time, :finishing_time, :location])
    |> validate_required([:name, :description, :date, :starting_time, :finishing_time, :location])
  end

  def user_changeset(changeset, users) do
    put_assoc(changeset, :users, users)
  end
end
