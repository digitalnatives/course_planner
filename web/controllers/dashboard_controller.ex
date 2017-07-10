defmodule CoursePlanner.DashboardController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
