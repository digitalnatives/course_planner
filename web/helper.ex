defmodule CoursePlanner.Helper do
  import Plug.Conn
  import Phoenix.Controller

  def handle_unauthorized(conn) do
    conn
    |> put_status(403)
    |> render(CoursePlanner.ErrorView, "403.html")
  end

end
