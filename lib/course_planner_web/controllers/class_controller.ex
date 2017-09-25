defmodule CoursePlannerWeb.ClassController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.{Classes, Attendances, Terms}

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.html", terms: Terms.all_for_classes())
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Classes.new())
  end

  def create(%{assigns: %{current_user: current_user}} = conn, %{"class" => class_params}) do
    case Classes.create(class_params) do
      {:ok, class} ->

        Classes.notify_class_students(class,
          current_user,
          :class_subscribed,
          offered_course_url(conn, :show, class.offered_course_id))

        preload_class = Repo.preload(class, :students)
        Attendances.create_class_attendance_records(preload_class.id, preload_class.students)

        conn
        |> put_flash(:info, "Class created successfully.")
        |> redirect(to: class_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, class, changeset} <- Classes.edit(id),
    do: render(conn, "edit.html", class: class, changeset: changeset)
  end

  def update(
    %{assigns: %{current_user: current_user}} = conn,
    %{"id" => id, "class" => class_params}) do

    case Classes.update(id, class_params) do
      {:ok, class} ->
        Classes.notify_class_students(class,
          current_user,
          :class_updated,
          offered_course_url(conn, :show, class.offered_course_id))
        conn
        |> put_flash(:info, "Class updated successfully.")
        |> redirect(to: class_path(conn, :index))
      {:error, class, changeset} ->
        render(conn, "edit.html", class: class, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    case Classes.delete(id) do
      {:ok, class} ->
        Classes.notify_class_students(class, current_user, :class_deleted)
        conn
        |> put_flash(:info, "Class deleted successfully.")
        |> redirect(to: class_path(conn, :index))
      {:error, :not_found} -> {:error, :not_found}
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: class_path(conn, :index))
    end
  end
end
