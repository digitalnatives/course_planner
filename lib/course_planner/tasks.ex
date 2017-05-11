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
    case Repo.one(from t in Task, where: is_nil(t.deleted_at) and t.id == ^id) do
      nil  -> {:error, :not_found}
      task -> {:ok, Repo.preload(task, :user)}
    end
  end

  def new(%{"user_id" => "0"} = params), do: new(Map.delete(params, "user_id"))
  def new(params) do
    %Task{}
    |> Task.changeset(params)
    |> Statuses.update_status_timestamp(TaskStatus)
    |> Repo.insert()
  end

  def update(id, params) do
    case get(id) do
      {:ok, task} ->
        task
        |> Task.changeset(params)
        |> Statuses.update_status_timestamp(TaskStatus)
        |> Repo.update()
        |> format_error(task)
      error -> error
    end
  end

  defp format_error({:ok, task}, _), do: {:ok, task}
  defp format_error({:error, changeset}, task), do: {:error, task, changeset}

  def delete(id) do
    case get(id) do
      {:ok, task} ->
        task
        |> Task.changeset()
        |> Changeset.put_change(:deleted_at, DateTime.utc())
        |> Repo.update()
      error -> error
    end
  end

end
