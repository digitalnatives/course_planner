defmodule CoursePlanner.JsonLogin do
  @moduledoc """
  This module implements a login callback for json connection
  """
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [render: 3]

  def callback(conn) do
    conn
    |> put_status(401)
    |> render(CoursePlanner.ErrorView, "401.json")
  end
end
