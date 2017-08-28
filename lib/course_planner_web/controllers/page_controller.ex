defmodule CoursePlannerWeb.PageController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  import Canary.Plugs
  plug :authorize_controller

  def index(conn, _params) do
    conn
    |> put_status(301)
    |> redirect(to: summary_path(conn, :show))
  end
end
