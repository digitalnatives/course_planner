defmodule CoursePlanner.Statuses do
  @moduledoc """
    Updates the status timestamps whenever there is a status change in a resource.
    It assumes the resource has a field called status of type CoursePlanner.Types.EntityStatus.
  """
  import Ecto.Changeset, only: [put_change: 3, get_change: 2]
  alias CoursePlanner.Types.EntityStatus

  @timestamp_fields Enum.into(
    EntityStatus.values, %{}, fn status ->
      {status, :"#{String.downcase(status)}_at"}
    end)

  def update_status_timestamp(changeset) do
    if changeset.valid? && get_change(changeset, :status) do
      case @timestamp_fields[get_change(changeset, :status)] do
        nil -> changeset
        timestamp_field -> put_change(changeset, timestamp_field, Timex.now)
      end
    else
      changeset
    end
  end
end
