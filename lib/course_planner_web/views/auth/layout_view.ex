defmodule CoursePlannerWeb.Auth.LayoutView do
  @moduledoc false
  use CoursePlannerWeb, :view

  def layout_title() do
    Application.get_env(:course_planner, :auth_email_title)
  end
end
