defmodule CoursePlannerWeb.ScheduleController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias Guardian.Plug

  import Canary.Plugs
  plug :authorize_controller

  def show(%{assigns: %{current_user: current_user}} = conn, params) do
    jwt =
      conn
      |> Plug.api_sign_in(current_user)
      |> Plug.current_token()

    conn
    |> render("show.html", params: params, jwt: jwt)
  end
end
