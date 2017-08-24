defmodule CoursePlannerWeb.CustomRoute do
  @moduledoc """
    Define custom route helpers, like *_path and *_url
  """
  alias   CoursePlannerWeb.Endpoint

  def user_show_url(user) do
    Endpoint.url <> user_show_path(user)
  end

  def user_show_path(user) do
    case user.role do
      "Student" -> "/students/#{user.id}"
      "Teacher" -> "/teachers/#{user.id}"
      "Coordinator" -> "/coordinators/#{user.id}"
      "Volunteer" -> "/volunteers/#{user.id}"
      _ -> "#"
    end
  end
end
