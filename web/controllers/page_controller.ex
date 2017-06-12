defmodule CoursePlanner.PageController do
  use CoursePlanner.Web, :controller

  def index(conn, _params) do
    conn
    |> put_status(301)
    |> redirect(to: dashboard_path(conn, :show))
  end
end
