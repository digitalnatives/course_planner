defmodule CoursePlanner.Tasks do
  @moduledoc false
  alias CoursePlanner.{Repo, Volunteers, Tasks.Task}
  alias Ecto.Changeset
  import Ecto.Query, except: [update: 2]

  def all do
    Repo.all(Task)
  end
  def all_with_users, do: all() |> Repo.preload(:volunteers)

  def get(id) do
    case Repo.get(Task, id) do
      nil  -> {:error, :not_found}
      task -> {:ok, Repo.preload(task, :volunteers)}
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

  def get_availables(sort_opt, id, now) do
    sort_opt
    |> task_query()
    |> where([t], t.finish_time > ^now)
    |> Repo.all()
    |> Enum.reject(fn(task) ->
         length(task.volunteers) > task.max_volunteer or
           Enum.any?(task.volunteers, &(&1.id == id))
       end)
  end

  def get_past(sort_opt, id, now) do
    sort_opt
    |> task_query()
    |> where([t], t.finish_time < ^now)
    |> Repo.all()
    |> Enum.reject(fn(task) ->
         not Enum.any?(task.volunteers, &(&1.id == id))
       end)
  end

  def get_for_user(sort_opt, id, now) do
    sort_opt
    |> task_query()
    |> where([t], t.finish_time > ^now)
    |> Repo.all()
    |> Enum.reject(fn(task) ->
         not Enum.any?(task.volunteers, &(&1.id == id))
       end)
  end

  def task_query(sort_opt) do
     Task
     |> sort(sort_opt)
     |> preload(:volunteers)
  end

  defp sort(query, nil), do: query
  defp sort(query, "fresh"), do: order_by(query, [t], desc: t.updated_at)
  defp sort(query, "closest"), do: order_by(query, [t], asc: t.finish_time)

  def grab(task_id, volunteer_id, now) do
    with {:ok, task}              <- get(task_id),
      %{valid?: true} = changeset <- Task.changeset(task),
      {:ok, changeset}            <- validate_finish_time(changeset, now)
    do
      new_volunteer = Volunteers.get!(volunteer_id)
      updated_volunteer_list = [new_volunteer | task.volunteers]

      changeset
      |> Changeset.put_assoc(:volunteers, updated_volunteer_list)
      |> Repo.update()
    else
      error -> error
    end
  end

  def drop(task_id, volunteer_id, now) do
    with {:ok, task}              <- get(task_id),
      %{valid?: true} = changeset <- Task.changeset(task)
    do
      drop_volunteer = Volunteers.get!(volunteer_id)
      updated_volunteer_list =
        task.volunteers
        |> List.delete(drop_volunteer)

      changeset
      |> Changeset.put_assoc(:volunteers,  updated_volunteer_list)
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
