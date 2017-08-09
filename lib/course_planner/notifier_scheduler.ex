defmodule CoursePlanner.NotifierScheduler do
  @moduledoc false
  use Quantum.Scheduler,
    otp_app: :course_planner
end
