defmodule CoursePlanner.Term do
  use CoursePlanner.Web, :model

  schema "terms" do
    field :name, :string
    field :starting_day, Ecto.Date
    field :finishing_day, Ecto.Date
    field :holidays, {:array, Ecto.Date}
    field :status, :string
    field :frozen_at, Ecto.DateTime
    field :finished_at, Ecto.DateTime
    field :deleted_at, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :starting_day, :finishing_day, :holidays, :status, :frozen_at, :finished_at, :deleted_at])
    |> validate_required([:name, :starting_day, :finishing_day, :status])
  end
end
