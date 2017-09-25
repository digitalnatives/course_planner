defmodule CoursePlannerWeb.OfferedCourseController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.{
    Attendances,
    Classes,
    Courses.OfferedCourses,
    Accounts.Teachers,
    Terms
  }

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

  def index(%{assigns: %{current_user: current_user}} = conn, _params) do
    terms = Terms.find_all_by_user(current_user)
    render(conn, "index.html", terms: terms)
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: OfferedCourses.new())
  end

  def create(conn, %{"offered_course" => params}) do
    case OfferedCourses.insert(params) do
      {:ok, _offered_course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: offered_course_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%{assigns: %{current_user: %{role: user_role}}} = conn, %{"id" => id})
  when user_role in ["Coordinator", "Teacher"] do
    with {:ok, offered_course} <-
            OfferedCourses.get(id, [:term, :course, :students, :teachers, :classes]),
         {past_classes, next_classes} <-
            offered_course.classes
            |> Classes.sort_by_starting_time()
            |> Classes.split_past_and_next()
    do
      render(conn, "show.html", offered_course: offered_course,
                              next_classes: next_classes,
                              past_classes: past_classes,
                              user_role: user_role)
    end
  end

  def show(%{assigns: %{current_user: %{role: user_role, id: user_id}}} = conn, %{"id" => id})
  when user_role == "Student" do
    with {:ok, offered_course} <-
           OfferedCourses.get(id, [:term, :course, :students, :teachers]),
         {past_classes, next_classes} <-
           id
           |> Classes.classes_with_attendances(user_id)
           |> Classes.split_past_and_next()
    do
    render(conn, "show.html", offered_course: offered_course,
                              next_classes: next_classes,
                              past_classes: past_classes,
                              user_role: user_role)
    end
  end

  def edit(%{assigns: %{current_user: %{role: user_role} = current_user}} = conn, %{"id" => id})
  when user_role == "Teacher" do
    with {:ok, offered_course, changeset} <- OfferedCourses.edit(id),
         true <- Teachers.can_update_offered_course?(current_user, offered_course)
    do
      render(conn, "teacher_edit.html", offered_course: offered_course, changeset: changeset)
    else
      false -> {:error, :forbidden}
    end
  end
  def edit(conn, %{"id" => id}) do
    with {:ok, offered_course, changeset} <- OfferedCourses.edit(id),
    do: render(conn, "edit.html", offered_course: offered_course, changeset: changeset)
  end

  def update(%{assigns: %{current_user: %{role: user_role} = current_user}} = conn,
  %{"id" => id, "offered_course" => %{"syllabus" => syllabus}}) when user_role == "Teacher" do
    with {:ok, offered_course} <- OfferedCourses.get(id, [:term, :course, :students, :teachers]),
         true <- Teachers.can_update_offered_course?(current_user, offered_course),
         {:ok, updated_offered_course, _} <-
           OfferedCourses.update_syllabus(offered_course, syllabus)
    do
      conn
      |> put_flash(:info, "Course updated successfully.")
      |> redirect(to: offered_course_path(conn, :show, updated_offered_course))
    else
      {:error, offered_course, _, changeset} ->
        render(conn, "teacher_edit.html", offered_course: offered_course,
                                          changeset: changeset)
      false -> {:error, :forbidden}
    end
  end
  def update(conn, %{"id" => id, "offered_course" => params}) do
    with {:ok, offered_course} <- OfferedCourses.get(id, [:term, :course, :students, :teachers]),
         {:ok, updated_offered_course, students} <- OfferedCourses.update(id, params)
    do
        Attendances.remove_students_attendances(offered_course.id,
                                                     offered_course.students, students)
        Attendances.create_students_attendances(offered_course.id,
                                                     offered_course.students, students)
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: offered_course_path(conn, :show, updated_offered_course))
    else
      {:error, offered_course, _, changeset} ->
        render(conn, "edit.html", offered_course: offered_course, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- OfferedCourses.delete(id)
    do
        conn
        |> put_flash(:info, "Course deleted successfully.")
        |> redirect(to: offered_course_path(conn, :index))
    end
  end
end
