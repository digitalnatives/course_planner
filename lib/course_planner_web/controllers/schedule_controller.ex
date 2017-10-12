defmodule CoursePlannerWeb.ScheduleController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  import Canary.Plugs
  plug :authorize_controller

  def show(conn, params) do
    conn
    |> render("show.html", params: params)
  end
end
