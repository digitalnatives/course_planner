defmodule CoursePlanner.TaskController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Tasks, Tasks.Task}

  import Canary.Plugs
  plug :authorize_controller

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
    case Tasks.get(id) do
      {:ok, task} ->
        render(conn, "show.html", task: task)
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      end
  end

  def edit(conn, %{"id" => id}) do
    case Tasks.get(id) do
      {:ok, task} ->
        render(conn, "edit.html", task: task, changeset: Task.changeset(task))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
    end
  end

  def update(conn, %{"id" => id, "task" => task_params})do
    with {:ok, task} <- Tasks.get(id)
     do
       volunteer_ids = Map.get(task_params, "volunteer_ids", [])

       changeset = task
         |> Repo.preload([:volunteers])
         |> Task.changeset(task_params, :update)
         |> Tasks.update_changeset_volunteers(volunteer_ids)

       case Repo.update(changeset) do
         {:ok, task} ->
           conn
           |> put_flash(:info, "Task updated successfully.")
           |> redirect(to: task_path(conn, :show, task))
         {:error, :not_found} ->
           conn
           |> put_status(404)
           |> render(CoursePlanner.ErrorView, "404.html")
         {:error, changeset} ->
           render(conn, "edit.html", task: task, changeset: changeset)
       end
     else
       _ -> conn
            |> put_status(404)
            |> render(CoursePlanner.ErrorView, "404.html")
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
    grab_and_drop_common_handling(conn, :grab, task_id, volunteer_id)
  end

  def drop(%{assigns: %{current_user: %{id: volunteer_id}}} = conn, %{"task_id" => task_id}) do
    grab_and_drop_common_handling(conn, :drop, task_id, volunteer_id)
  end

  defp grab_and_drop_common_handling(conn, action, task_id, volunteer_id) do
    {transaction_result, success_message} =
      case action do
        :grab -> {Tasks.grab(task_id, volunteer_id), "Task grabbed."}
        :drop -> {Tasks.drop(task_id, volunteer_id), "Task dropped."}
      end

    case transaction_result do
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
