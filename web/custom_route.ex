defmodule CoursePlanner.CustomRoute do
  @moduledoc """
    Define custom route helpers, like *_path and *_url
  """

  def user_show_url(user) do
    case user.role do
      "Student" -> "/students/#{user.id}"
      "Teacher" -> "/teachers/#{user.id}"
      "Coordinator" -> "/coordinators/#{user.id}"
      "Volunteer" -> "/volunteers/#{user.id}"
      _ -> "#"
    end
  end
end
