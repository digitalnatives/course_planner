defmodule CoursePlannerWeb.Helper do
  @moduledoc """
    Helper function for canary
  """
  import Plug.Conn
  import Phoenix.Controller

  def handle_unauthorized(conn) do
    conn
    |> put_status(403)
    |> render(CoursePlannerWeb.ErrorView, "403.html")
    |> halt()
  end

end
