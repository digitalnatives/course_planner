defmodule CoursePlannerWeb.DashboardController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  import Canary.Plugs
  plug :authorize_controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
