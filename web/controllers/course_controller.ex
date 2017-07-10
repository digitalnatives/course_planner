defmodule CoursePlanner.CourseController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Repo, Course, CourseHelper}

  import Canary.Plugs
  plug :authorize_resource, model: Course

  def index(conn, _params) do
    courses = Repo.all(Course)
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

  def show(conn, %{"id" => id}) do
    case Repo.get(Course, id) do
      nil ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      course ->
        render(conn, "show.html", course: course)
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
        CourseHelper.notify_user_course(course,
          current_user,
          :course_updated,
          course_url(conn, :show, course))
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: course_path(conn, :show, course))
      {:error, changeset} ->
        render(conn, "edit.html", course: course, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    case CourseHelper.delete(id) do
      {:ok, course} ->
        CourseHelper.notify_user_course(course, current_user, :course_deleted)
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
