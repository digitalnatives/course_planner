defmodule CoursePlanner.Course do
  use CoursePlanner.Web, :model

  schema "courses" do
    field :name, :string
    field :weekday, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :weekday])
    |> validate_required([:name, :weekday])
  end
end
