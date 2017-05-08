defmodule CoursePlanner.ClassController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{Class, ClassHelper}

  def index(conn, _params) do
    classes = ClassHelper.all_none_deleted()
    render(conn, "index.html", classes: classes)
  end

  def new(conn, _params) do
    changeset = Class.changeset(%Class{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"class" => class_params}) do
    changeset = Class.changeset(%Class{}, class_params, :create)

    case Repo.insert(changeset) do
      {:ok, _class} ->
        conn
        |> put_flash(:info, "Class created successfully.")
        |> redirect(to: class_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    class = Repo.get!(Class, id)
    render(conn, "show.html", class: class)
  end

  def edit(conn, %{"id" => id}) do
    class = Repo.get!(Class, id)
    changeset = Class.changeset(class)
    render(conn, "edit.html", class: class, changeset: changeset)
  end

  def update(conn, %{"id" => id, "class" => class_params}) do
    class = Repo.get!(Class, id)
    changeset = Class.changeset(class, class_params, :update)

    case Repo.update(changeset) do
      {:ok, class} ->
        conn
        |> put_flash(:info, "Class updated successfully.")
        |> redirect(to: class_path(conn, :show, class))
      {:error, changeset} ->
        render(conn, "edit.html", class: class, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    class = Repo.get!(Class, id)
    ClassHelper.delete(class)

    conn
    |> put_flash(:info, "Class deleted successfully.")
    |> redirect(to: class_path(conn, :index))
  end
end
