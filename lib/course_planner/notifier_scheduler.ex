defmodule CoursePlanner.NotifierScheduler do
  @moduledoc false
  use Quantum.Scheduler,
    otp_app: :course_planner

  alias CoursePlanner.Notifications

  def init(config) do
    Notifications.wake_up()
    config
  end
end
