defmodule CoursePlanner.LayoutView do
  @moduledoc false
  use CoursePlanner.Web, :view

  alias CoursePlanner.Settings

  def show_program_about? do
    Settings.get_value("SHOW_PROGRAM_ABOUT_PAGE")
  end

  def get_program_name do
    Settings.get_value("PROGRAM_NAME")
  end

  def render_user_role_based_navbar(%{assigns: %{current_user: current_user}} = conn) do
    case current_user.role do
      "Coordinator" -> render("coordinator_app_navbar.html", conn: conn)
      "Student" -> render("student_app_navbar.html", conn: conn)
      "Teacher" -> render("teacher_app_navbar.html", conn: conn)
      "Volunteer" -> render("volunteer_app_navbar.html", conn: conn)
    end
  end
end
