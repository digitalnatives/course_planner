defmodule CoursePlanner.Mailer.Main do
  @moduledoc """
  This module is needed as the main center for swoosh to be accessed in the app
  """
  use Swoosh.Mailer, otp_app: :course_planner
end
