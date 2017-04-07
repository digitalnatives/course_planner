defmodule CoursePlanner.Course do
  use CoursePlanner.Web, :model

  schema "courses" do
    field :name, :string
    field :teacher, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :teacher])
    |> validate_required([:name, :teacher])
  end
end
