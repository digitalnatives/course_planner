defmodule CoursePlanner.AttendanceHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Attendance}

  def get_class_attendance_info(class_id) do
    Repo.all(
        from a in Attendance,
          preload: [{:class, :offered_course}, :student],
          where: ^class_id == a.class_id)
  end
end
