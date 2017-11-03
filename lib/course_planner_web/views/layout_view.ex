defmodule CoursePlannerWeb.LayoutView do
  @moduledoc false
  use CoursePlannerWeb, :view

  alias CoursePlanner.Settings

  @navbars %{"Coordinator" => "coordinator_app_navbar.html",
             "Supervisor" => "coordinator_app_navbar.html",
             "Student" => "student_app_navbar.html",
             "Teacher" => "teacher_app_navbar.html",
             "Volunteer" => "volunteer_app_navbar.html"}

  def show_program_about? do
    Settings.get_value("SHOW_PROGRAM_ABOUT_PAGE")
  end

  def get_program_name do
    Settings.get_value("PROGRAM_NAME")
  end

  def render_user_role_based_navbar(%{assigns: %{current_user: %{role: role}}} = conn)
    when role in ["Coordinator", "Supervisor", "Student", "Teacher", "Volunteer"] do
    render(@navbars[role], conn: conn)
  end
  def render_user_role_based_navbar(_conn), do: nil
end
