defmodule CoursePlannerWeb.CourseController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.Courses

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.html", courses: Courses.all())
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Courses.new())
  end

  def create(conn, %{"course" => course_params}) do
    case Courses.insert(course_params) do
      {:ok, _course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: course_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, course, changeset} <- Courses.edit(id),
    do: render(conn, "edit.html", course: course, changeset: changeset)
  end

  def update(
    %{assigns: %{current_user: current_user}} = conn,
    %{"id" => id, "course" => course_params}) do

    case Courses.update(id, course_params) do
      {:ok, course} ->
        Courses.notify_user_course(course,
          current_user,
          :course_updated,
          course_url(conn, :index))
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: course_path(conn, :index))
      {:error, course, changeset} ->
        render(conn, "edit.html", course: course, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    case Courses.delete(id) do
      {:ok, course} ->
        Courses.notify_user_course(course, current_user, :course_deleted)
        conn
        |> put_flash(:info, "Course deleted successfully.")
        |> redirect(to: course_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Course was not found.")
        |> redirect(to: course_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: course_path(conn, :index))
    end
  end
end
