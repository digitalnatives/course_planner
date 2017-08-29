defmodule CoursePlanner.Terms.Holiday do
  @moduledoc """
    Defines the Holiday structure which is embedded in a Term
  """
  use CoursePlannerWeb, :model

  alias Ecto.{Changeset}

  embedded_schema do
    field :date, :date
    field :description, :string
  end

  def changeset(struct, start_date, end_date, params \\ %{}) do
    struct
    |> cast(params, [:date, :description])
    |> validate_required([:date])
    |> validate_date_between(start_date, end_date)
  end

  def validate_date_between(%{valid?: true} = changeset, start_date, end_date) do
    date = Changeset.get_field(changeset, :date)
    cond do
      Date.compare(date, start_date) == :lt ->
        Changeset.add_error(changeset, :date, "is before term's beginning")
      Date.compare(date, end_date) == :gt ->
        Changeset.add_error(changeset, :date, "is after term's ending")
      true ->
        changeset
    end
  end
  def validate_date_between(changeset, _start_date, _end_date), do: changeset
end
