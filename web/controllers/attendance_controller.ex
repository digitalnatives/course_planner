defmodule CoursePlanner.AttendanceController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.AttendanceHelper

  def index(%{assigns: %{current_user: %{id: _id, role: "Coordinator"}}} = conn, _params) do
    offered_courses = AttendanceHelper.get_all_offered_courses()

    render(conn, "index.html", offered_courses: offered_courses, role: :coordinator)
  end

  def index(%{assigns: %{current_user: %{id: id, role: "Teacher"}}} = conn, _params) do
    offered_courses = AttendanceHelper.get_all_teacher_offered_courses(id)

    render(conn, "index.html", offered_courses: offered_courses, role: :teacher)
  end

  def index(%{assigns: %{current_user: %{id: id, role: "Student"}}} = conn, _params) do
    offered_courses = AttendanceHelper.get_all_student_offered_courses(id)

    render(conn, "index.html", offered_courses: offered_courses, role: :student)
  end
end
