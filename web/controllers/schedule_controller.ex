defmodule CoursePlanner.ScheduleController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Schedule

  import Canary.Plugs
  plug :authorize_controller

  def show(conn, params) do
    render(conn, "show.html", params: params)
  end
end
