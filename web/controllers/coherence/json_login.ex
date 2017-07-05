defmodule CoursePlanner.JsonLogin do
  @moduledoc """
  This module implements a login callback for json connection
  """
  use CoursePlanner.Web, :controller

  def callback(conn) do
    conn
    |> put_status(401)
    |> render(CoursePlanner.ErrorView, "401.json")
  end
end
