defmodule CoursePlannerWeb.FallbackController do
  @moduledoc """
  Fallback module for controllers that doesn't return `Plug.Conn`
  """
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(CoursePlannerWeb.ErrorView, "404.html")
  end
  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render(CoursePlannerWeb.ErrorView, "403.html")
  end
  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> render("500.html")
  end

end
