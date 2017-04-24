defmodule CoursePlanner.Statuses do
  @moduledoc """
    Updates the status timestamps whenever there is a status change in a resource.
    It assumes the resource has a field called status of type CoursePlanner.Types.EntityStatus.
  """
  import Ecto.Changeset, only: [put_change: 3]

  def update_status_timestamp(changeset) do
    if changeset.valid? && changeset.changes[:status] do
      case changeset.changes[:status] do
        "Planned" -> put_change(changeset, :planned_at, Timex.now)
        "Active" -> put_change(changeset, :activated_at, Timex.now)
        "Frozen" -> put_change(changeset, :froze_at, Timex.now)
        "Finished" -> put_change(changeset, :finished_at, Timex.now)
        "Deleted" -> put_change(changeset, :deleted_at, Timex.now)
        _ -> changeset
      end
    else
      changeset
    end
  end
end
