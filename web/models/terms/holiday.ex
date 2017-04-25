defmodule CoursePlanner.Terms.Holiday do
  @moduledoc """
    Defines the Holiday structure which is embedded in a Term
  """
  use CoursePlanner.Web, :model

  embedded_schema do
    field :date, :date
    field :description, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :description])
    |> validate_required([:date])
  end
end
