defmodule CoursePlanner.DummySchema do
  use CoursePlanner.Web, :model

  embedded_schema do
    field :name, :string
    field :status, :string
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:name, :status])
  end
end

defmodule CoursePlanner.StatusesTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{DummySchema, Statuses}
  alias Ecto.Changeset
  alias CoursePlanner.Types.EntityStatus

  test "do nothing when changeset is invalid" do
    changeset =
      %DummySchema{}
      |> DummySchema.changeset()
      |> Changeset.add_error(:name, "error")

    refute changeset.valid?

    assert changeset == Statuses.update_status_timestamp(changeset, EntityStatus)
  end

  test "do nothing when there is no status change" do
    changeset = DummySchema.changeset(%DummySchema{})

    assert Changeset.get_change(changeset, :status) == nil
    assert changeset == Statuses.update_status_timestamp(changeset, EntityStatus)
  end

  test "do nothing when the status is not one of EntityStatus values" do
    changeset = DummySchema.changeset(%DummySchema{}, %{status: "Dummy"})
    assert changeset == Statuses.update_status_timestamp(changeset, EntityStatus)
  end

  test "set timestamp status when the status is one of EntityStatus values" do
    changeset = DummySchema.changeset(%DummySchema{}, %{status: "Active"})
    assert Changeset.get_change(changeset, :active_at) == nil

    changeset = Statuses.update_status_timestamp(changeset, EntityStatus)
    refute Changeset.get_change(changeset, :active_at) == nil
  end
end
