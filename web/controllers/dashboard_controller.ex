defmodule CoursePlanner.DashboardController do
  use CoursePlanner.Web, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
