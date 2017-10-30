defmodule CoursePlannerWeb.CourseController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.{Repo, Courses.Course, Courses}

  import Canary.Plugs
  plug :authorize_controller

  def index(conn, _params) do
    query = from c in Course, order_by: [asc: c.name]
    courses = Repo.all(query)

    render(conn, "index.html", courses: courses)
  end

  def new(conn, _params) do
    changeset = Course.changeset(%Course{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course" => course_params}) do
    changeset = Course.changeset(%Course{}, course_params, :create)

    case Repo.insert(changeset) do
      {:ok, _course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: course_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    course = Repo.get!(Course, id)
    changeset = Course.changeset(course)
    render(conn, "edit.html", course: course, changeset: changeset)
  end

  def update(
    %{assigns: %{current_user: current_user}} = conn,
    %{"id" => id, "course" => course_params}) do

    course = Repo.get!(Course, id)
    changeset = Course.changeset(course, course_params)

    case Repo.update(changeset) do
      {:ok, course} ->
        Courses.notify_user_course(course,
          current_user,
          :course_updated,
          course_url(conn, :index))
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: course_path(conn, :index))
      {:error, changeset} ->
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
