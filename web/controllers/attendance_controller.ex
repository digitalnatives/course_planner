defmodule CoursePlanner.AttendanceController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{AttendanceHelper, OfferedCourse}

  def index(%{assigns: %{current_user: %{id: _id, role: "Coordinator"}}} = conn, _params) do
    offered_courses = AttendanceHelper.get_all_offered_courses()

    render(conn, "index_coordinator.html", offered_courses: offered_courses)
  end

  def index(%{assigns: %{current_user: %{id: id, role: "Teacher"}}} = conn, _params) do
    offered_courses = AttendanceHelper.get_all_teacher_offered_courses(id)

    render(conn, "index_teacher.html", offered_courses: offered_courses)
  end

  def index(%{assigns: %{current_user: %{id: id, role: "Student"}}} = conn, _params) do
    offered_courses = AttendanceHelper.get_all_student_offered_courses(id)

    render(conn, "index_student.html", offered_courses: offered_courses)
  end

  def show(%{assigns: %{current_user: %{id: _id, role: "Coordinator"}}} = conn,
           %{"id" => offered_course_id}) do
    case AttendanceHelper.get_course_attendances(offered_course_id) do
      nil ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      offered_course ->
        render(conn, "show_coordinator.html", offered_course: offered_course)
    end
  end

  def show(%{assigns: %{current_user: %{id: _id, role: "Teacher"}}} = conn,
           %{"id" => offered_course_id}) do
    case AttendanceHelper.get_course_attendances(offered_course_id) do
      nil ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
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

    case AttendanceHelper.get_student_attendances(offered_course_id, id) do
     [] ->
       conn
       |> put_status(404)
       |> render(CoursePlanner.ErrorView, "404.html")
     attendances ->
       render(conn, "show_student.html", attendances: attendances, offered_course: offered_course)
    end
  end
end
