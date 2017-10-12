defmodule CoursePlanner.Auth.GuardianErrorHandler do
  @moduledoc """
    Handles the case in which user tries accessing a resource without being loged-in
  """
  import CoursePlannerWeb.Router.Helpers

  alias Phoenix.Controller

  def unauthenticated(conn, _params) do
    conn
    |> Controller.put_flash(:error, "You must be signed in to access that page.")
    |> Controller.redirect(to: session_path(conn, :new))
  end
end
