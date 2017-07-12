defmodule CoursePlanner.Tasks do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.Tasks.Task
  alias Ecto.Changeset
  import Ecto.Query, except: [update: 2]

  def all do
    Repo.all(Task)
  end
  def all_with_users, do: all() |> Repo.preload(:user)

  def get(id) do
    case Repo.get(Task, id) do
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

  def update(id, %{"user_id" => "0"} = params), do: update(id, Map.delete(params, "user_id"))
  def update(id, params) do
    case get(id) do
      {:ok, task} ->
        task
        |> Task.changeset(params)
        |> Repo.update()
        |> format_error(task)
      error  -> error
    end
  end

  defp format_error({:ok, task}, _), do: {:ok, task}
  defp format_error({:error, changeset}, task), do: {:error, task, changeset}

  def delete(id) do
    case get(id) do
      {:ok, task} ->
        Repo.delete(task)
      error -> error
    end
  end

  def get_for_user(id, now) do
    Repo.all(from t in Task, where: t.user_id == ^id and t.finish_time > ^now, preload: [:user])
  end

  def get_unassigned(now) do
    Repo.all(from t in Task, where: is_nil(t.user_id) and t.finish_time > ^now)
  end

  def get_past_tasks(id, now) do
    Repo.all(from t in Task, where: t.user_id == ^id and t.finish_time < ^now, preload: [:user])
  end

  def grab(task_id, user_id, now) do
    with {:ok, task}              <- get(task_id),
      %{valid?: true} = changeset <- Task.changeset(task),
      {:ok, changeset}            <- validate_finish_time(changeset, now),
      {:ok, changeset}            <- validate_already_assigned(changeset, task)
    do
      changeset
      |> Changeset.put_change(:user_id, user_id)
      |> Repo.update()
    else
      error -> error
    end
  end

  defp validate_finish_time(changeset, now) do
    fin = Changeset.get_field(changeset, :finish_time)
    case Timex.compare(fin, now) do
      1  -> {:ok, changeset}
      -1 -> {:error, :already_finished}
      _  -> {:error, :unkown}
    end
  end

  defp validate_already_assigned(changeset, %{user_id: nil}), do: {:ok, changeset}
  defp validate_already_assigned(_changeset, _), do: {:error, :already_assigned}
end
