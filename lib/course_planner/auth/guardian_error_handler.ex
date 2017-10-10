defmodule CoursePlanner.Auth.GuardianErrorHandler do
  import CoursePlannerWeb.Router.Helpers
  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, "You must be signed in to access that page.")
    |> Phoenix.Controller.redirect(to: session_path(conn, :new))
  end
end
