defmodule CoursePlanner.Terms.Term do
  @moduledoc """
    Defines the Term, usually a semester, in which courses take place
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.Statuses
  alias CoursePlanner.Terms.Holiday
  alias CoursePlanner.Types.EntityStatus

  schema "terms" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    embeds_many :holidays, Holiday

    field :status, EntityStatus
    field :planned_at, :naive_datetime
    field :active_at, :naive_datetime
    field :frozen_at, :naive_datetime
    field :finished_at, :naive_datetime
    field :deleted_at, :naive_datetime

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :start_date, :end_date, :status])
    |> validate_required([:name, :start_date, :end_date, :status])
    |> cast_embed(:holidays)
    |> Statuses.update_status_timestamp(EntityStatus.timestamp_field())
  end
end
