defmodule CoursePlannerWeb.JsonLogin do
  @moduledoc """
  This module implements a login callback for json connection
  """
  import Plug.Conn, only: [put_status: 2, halt: 1]
  import Phoenix.Controller, only: [render: 3]

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(CoursePlannerWeb.ErrorView, "401.json")
    |> halt()
  end
end
