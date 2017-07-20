defmodule CoursePlanner.TaskController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Tasks
  alias CoursePlanner.Tasks.Task
  alias CoursePlanner.Volunteers

  import Canary.Plugs
  plug :authorize_controller

  def index(%{assigns: %{current_user: %{id: id, role: "Volunteer"}}} = conn, params) do
    sort_opt = Map.get(params, "sort", nil)
    now = Timex.now()
    render(conn, "index_volunteer.html",
      available_tasks: Tasks.get_unassigned(sort_opt, now),
      your_past_tasks: Tasks.get_past(sort_opt, id, now),
      your_tasks: Tasks.get_for_user(sort_opt, id, now))
  end

  def index(conn, _params) do
    render(conn, "index.html", tasks: Tasks.all_with_users())
  end

  def new(conn, _params) do
    render(conn, "new.html",
      changeset: %Task{} |> Task.changeset(),
      users: Volunteers.all())
  end

  def create(conn, %{"task" => task}) do
    case Tasks.new(task) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: task_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, users: Volunteers.all())
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
        render(conn, "edit.html",
          task: task,
          changeset: Task.changeset(task),
          users: Volunteers.all())
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
    end
  end

  def update(conn, %{"id" => id, "task" => params}) do
    case Tasks.update(id, params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: task_path(conn, :show, task))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, task, changeset} ->
        render(conn, "edit.html", task: task, changeset: changeset, users: Volunteers.all())
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

  @error_messages %{
    not_found: "Task was not found.",
    already_finished: "Cannott grab as task is already finished.",
    already_assigned: "Cannot grab as task is already assigned."
  }

  def grab(%{assigns: %{current_user: %{id: user_id}}} = conn, %{"task_id" => task_id}) do
    case Tasks.grab(task_id, user_id, Timex.now()) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task grabbed.")
        |> redirect(to: task_path(conn, :index))
      {:error, type} ->
        conn
        |> put_flash(:error, Map.get(@error_messages, type, "Something went wrong."))
        |> redirect(to: task_path(conn, :index))
    end
  end

end
