defmodule CoursePlanner.Tasks do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.Tasks.{Task, TaskStatus}
  alias CoursePlanner.Statuses
  alias Ecto.{DateTime, Changeset}
  import Ecto.Query

  @tasks from t in Task, where: is_nil(t.deleted_at), preload: [:user]

  def all do
    Repo.all(@tasks)
  end

  def get(id) do
    Task
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  def new(params) do
    %Task{}
    |> Task.changeset(params)
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(Task, id) do
      nil -> {:error, :not_found}
      task ->
        task
        |> Task.changeset(params)
        |> Statuses.update_status_timestamp(TaskStatus)
        |> Repo.update()
        |> format_error(task)
    end
  end

  defp format_error({:ok, task}, _), do: {:ok, task}
  defp format_error({:error, changeset}, task), do: {:error, task, changeset}

  def delete(id) do
    case Repo.get(Task, id) do
      nil -> {:error, :not_found}
      task ->
        task
        |> Task.changeset()
        |> Changeset.put_change(:deleted_at, DateTime.utc())
        |> Repo.update()
    end
  end

end
