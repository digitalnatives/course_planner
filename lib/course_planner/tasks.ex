defmodule CoursePlanner.Tasks do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.Tasks.Task
  alias Ecto.{DateTime, Changeset}
<<<<<<< HEAD
  import Ecto.Query
=======
  import Ecto.Query, except: [update: 2]
>>>>>>> nonose/apply_for_task

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
    |> Repo.insert()
  end

<<<<<<< HEAD
=======
  def update(id, %{"user_id" => "0"} = params), do: update(id, Map.delete(params, "user_id"))
>>>>>>> nonose/apply_for_task
  def update(id, params) do
    case get(id) do
      {:ok, task} ->
        task
        |> Task.changeset(params)
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

<<<<<<< HEAD
=======
  def get_user_id(id) do
    Repo.all(from t in Task, where: is_nil(t.deleted_at) and t.user_id == ^id, preload: [:user])
  end

  def get_unassigned do
    Repo.all(from t in Task, where: is_nil(t.deleted_at) and is_nil(t.user_id))
  end

  def grab(task_id, user_id) do
    case get(task_id) do
      {:ok, task} ->
        task
        |> Task.changeset()
        |> Changeset.put_change(:user_id, user_id)
        |> Repo.update()
      error -> error
    end
  end

>>>>>>> nonose/apply_for_task
end
