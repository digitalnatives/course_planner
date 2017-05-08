defmodule CoursePlanner.Statuses do
  @moduledoc """
    Updates the status timestamps whenever there is a status change in a resource.
  """
  import Ecto.Changeset, only: [put_change: 3, get_change: 2]

  def update_status_timestamp(changeset, enum_timestamp) do
    if changeset.valid? && get_change(changeset, :status) do
      case enum_timestamp.types_timestamp()[get_change(changeset, :status)] do
        nil -> changeset
        timestamp_field -> put_change(changeset, timestamp_field, Timex.now)
      end
    else
      changeset
    end
  end
end
