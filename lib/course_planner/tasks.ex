defmodule CoursePlanner.Tasks do
  @moduledoc false
  alias CoursePlanner.{Repo, Volunteers, Tasks.Task}
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
           length(task.volunteers) >= task.max_volunteers or
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
     |> join(:left, [t], v in assoc(t, :volunteers))
     |> preload([t, v], [volunteers: v])
  end

  defp sort(query, nil), do: query
  defp sort(query, "fresh"), do: order_by(query, [t], desc: t.updated_at)
  defp sort(query, "closest"), do: order_by(query, [t], asc: t.finish_time)

  def grab(task_id, volunteer_id) do
    with {:ok, task} <- get(task_id),
        %{valid?: true} = changeset <- Task.changeset(task)
     do
      new_volunteer = Volunteers.get!(volunteer_id)
      updated_volunteer_list = [new_volunteer | task.volunteers]

      changeset
      |> Task.put_assoc(:volunteers, updated_volunteer_list, :limit_max_volunteers)
      |> Repo.update()
    else
      error -> error
    end
  end

  def drop(task_id, volunteer_id) do
    with {:ok, task} <- get(task_id),
        %{valid?: true} = changeset <- Task.changeset(task)
     do
      drop_volunteer = Volunteers.get!(volunteer_id)
      updated_volunteer_list = List.delete(task.volunteers, drop_volunteer)

      changeset
      |> Task.put_assoc(:volunteers, updated_volunteer_list)
      |> Repo.update()
    else
      error -> error
    end
  end
end
