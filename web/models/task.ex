defmodule CoursePlanner.Task do
  use CoursePlanner.Web, :model

  schema "tasks" do
    field :name, :string
    field :due, Ecto.Date

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :due])
    |> validate_required([:name, :due])
  end
end
