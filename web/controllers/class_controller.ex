defmodule CoursePlanner.ClassController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Class, ClassHelper}

  def index(conn, _params) do
    classes =
      ClassHelper.all_none_deleted()
      |> Repo.preload([:offered_course, offered_course: :term, offered_course: :course])
    render(conn, "index.html", classes: classes)
  end

  def new(conn, _params) do
    changeset = Class.changeset(%Class{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(%{assigns: %{current_user: current_user}} = conn, %{"class" => class_params}) do
    changeset = Class.changeset(%Class{}, class_params, :create)

    case Repo.insert(changeset) do
      {:ok, class} ->

        ClassHelper.notify_class_students(class, current_user, :class_subscribed)

        class
        |> Repo.preload(:students)
        |> ClassHelper.create_class_attendance_records()

        conn
        |> put_flash(:info, "Class created successfully.")
        |> redirect(to: class_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    class =
      Class
      |> Repo.get!(id)
      |> Repo.preload([:offered_course, offered_course: :term, offered_course: :course])
    render(conn, "show.html", class: class)
  end

  def edit(conn, %{"id" => id}) do
    class = Repo.get!(Class, id)
    changeset = Class.changeset(class)
    render(conn, "edit.html", class: class, changeset: changeset)
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "class" => class_params}) do
    class = Repo.get!(Class, id)
    changeset = Class.changeset(class, class_params, :update)

    case Repo.update(changeset) do
      {:ok, class} ->
        ClassHelper.notify_class_students(class, current_user, :class_updated)
        conn
        |> put_flash(:info, "Class updated successfully.")
        |> redirect(to: class_path(conn, :show, class))
      {:error, changeset} ->
        render(conn, "edit.html", class: class, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    case ClassHelper.delete(id) do
      {:ok, class} ->
        ClassHelper.notify_class_students(class, current_user, :class_deleted)
        conn
        |> put_flash(:info, "Class deleted successfully.")
        |> redirect(to: class_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
    end
  end
end
