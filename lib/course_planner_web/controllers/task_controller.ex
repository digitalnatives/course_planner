defmodule CoursePlannerWeb.TaskController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.{Tasks, Tasks.Task}

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

  @error_messages %{
    not_found: "Task was not found."
  }

  def index(%{assigns: %{current_user: %{id: id, role: "Volunteer"}}} = conn, params) do
    sort_opt = Map.get(params, "sort", nil)
    now = Timex.now()
    render(conn, "index_volunteer.html",
      available_tasks: Tasks.get_availables(sort_opt, id, now),
      your_past_tasks: Tasks.get_past(sort_opt, id, now),
      your_tasks: Tasks.get_for_user(sort_opt, id, now))
  end

  def index(conn, _params) do
    render(conn, "index.html", tasks: Tasks.all_with_users())
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: %Task{} |> Task.changeset())
  end

  def create(conn, %{"task" => task_params}) do
    volunteer_ids = Map.get(task_params, "volunteer_ids", [])

    changeset =  %Task{}
      |> Task.changeset(task_params)
      |> Tasks.update_changeset_volunteers(volunteer_ids)

    case Repo.insert(changeset) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: task_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
      _ ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: task_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, task} <- Tasks.get(id) do
      render(conn, "show.html", task: task)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, task} <- Tasks.get(id),
         changeset   <- Task.changeset(task)
    do
      render(conn, "edit.html", task: task, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    case Tasks.update(id, task_params) do
     {:ok, task} ->
       conn
       |> put_flash(:info, "Task updated successfully.")
       |> redirect(to: task_path(conn, :show, task))
     {:error, :not_found} -> {:error, :not_found}
     {:error, changeset} ->
       render(conn, "edit.html", task: id, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Tasks.delete(id) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task deleted successfully.")
        |> redirect(to: task_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Task was not found.")
        |> redirect(to: task_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: task_path(conn, :index))
    end
  end

  def grab(%{assigns: %{current_user: %{id: volunteer_id}}} = conn, %{"task_id" => task_id}) do
    task_id
    |> Tasks.grab(volunteer_id)
    |> format_response(conn, "Task grabbed")
  end

  def drop(%{assigns: %{current_user: %{id: volunteer_id}}} = conn, %{"task_id" => task_id}) do
    task_id
    |> Tasks.drop(volunteer_id)
    |> format_response(conn, "Task dropped")
  end

  defp format_response(response, conn, success_message) do
    case response do
      {:ok, _task} ->
        conn
        |> put_flash(:info, success_message)
        |> redirect(to: task_path(conn, :index))
      {:error, %{errors: errors}} ->
        [{_field, {error_message, []}}] =  errors

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: task_path(conn, :index))
      {:error, type} ->
        conn
        |> put_flash(:error, Map.get(@error_messages, type, "Something went wrong."))
        |> redirect(to: task_path(conn, :index))
    end
  end
end
