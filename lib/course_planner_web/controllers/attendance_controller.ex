defmodule CoursePlannerWeb.AttendanceController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.{Attendances, Attendances.Attendance, Courses.OfferedCourse}

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

  def index(%{assigns: %{current_user: %{id: _id, role: "Coordinator"}}} = conn, _params) do

    offered_courses = Attendances.get_all_offered_courses()

    render(conn, "index_coordinator.html", offered_courses: offered_courses)
  end

  def index(%{assigns: %{current_user: %{id: _id, role: "Supervisor"}}} = conn, _params) do

    offered_courses = Attendances.get_all_offered_courses()

    render(conn, "index_supervisor.html", offered_courses: offered_courses)
  end

  def index(%{assigns: %{current_user: %{id: id, role: "Teacher"}}} = conn, _params) do
    offered_courses = Attendances.get_all_teacher_offered_courses(id)

    render(conn, "index_teacher.html", offered_courses: offered_courses)
  end

  def index(%{assigns: %{current_user: %{id: id, role: "Student"}}} = conn, _params) do
    offered_courses = Attendances.get_all_student_offered_courses(id)

    render(conn, "index_student.html", offered_courses: offered_courses)
  end

  def show(%{assigns: %{current_user: %{id: _id, role: role}}} = conn,
           %{"id" => offered_course_id}) when role in ["Coordinator", "Supervisor"] do

    case Attendances.get_course_attendances(offered_course_id) do
      nil -> {:error, :not_found}
      offered_course ->
        render(conn, "show_coordinator.html", offered_course: offered_course)
    end
  end

  def show(%{assigns: %{current_user: %{id: id, role: "Teacher"}}} = conn,
           %{"id" => offered_course_id}) do
    case Attendances.get_teacher_course_attendances(offered_course_id, id) do
      nil -> {:error, :not_found}
      offered_course ->
        render(conn, "show_teacher.html", offered_course: offered_course)
    end
  end

  def show(%{assigns: %{current_user: %{id: id, role: "Student"}}} = conn,
           %{"id" => offered_course_id}) do
    offered_course =
    OfferedCourse
    |> Repo.get(offered_course_id)
    |> Repo.preload([:term, :course, :teachers])

    case Attendances.get_student_attendances(offered_course_id, id) do
     [] -> {:error, :not_found}
     attendances ->
       render(conn, "show_student.html", attendances: attendances, offered_course: offered_course)
    end
  end

  def fill_course(%{assigns: %{current_user: %{role: role}}} = conn, %{"attendance_id" => id})
    when role in ["Coordinator", "Teacher"] do

    offered_course = Attendances.get_course_attendances(id)

    changeset = OfferedCourse.changeset(offered_course)

    render(conn, "fill_course_attendance.html", offered_course: offered_course,
           changeset: changeset)
  end

  def update_fill(%{assigns: %{current_user: %{role: role}}} = conn,
       %{"offered_course" => %{"classes" => classes}, "attendance_id" => offered_course_id})
    when role in ["Coordinator", "Teacher"] do

      attendances_data =
        classes
        |> Map.values()
        |> Enum.flat_map(fn(class_value) ->
             Map.values(class_value["attendances"])
           end)

      attendance_changeset_list =
        attendances_data
        |> Enum.map(fn(attendance_params) ->
             attendance = Repo.get!(Attendance, attendance_params["id"])
             Attendance.changeset(attendance, attendance_params)
           end)

      case Attendances.update_multiple_attendances(attendance_changeset_list) do
        {:ok, _data} ->
          conn
          |> put_flash(:info, "attendances updated successfully.")
          |> redirect(to: attendance_path(conn, :show, offered_course_id))
        {:error, _failed_operation, _failed_value, _changes_so_far} ->
          offered_course = Attendances.get_course_attendances(offered_course_id)
          changeset = OfferedCourse.changeset(offered_course)
          conn
          |> put_flash(:error, "Something went wrong.")
          |> render("fill_course_attendance.html", offered_course: offered_course,
                 changeset: changeset)
      end
  end
end
