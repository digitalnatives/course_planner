defmodule CoursePlanner.CurrentUser do
  @moduledoc """
    this module is used by guardian through router to populate loged-in user
  """
  import Plug.Conn
  import Guardian.Plug

  def init(opts), do: opts
  def call(conn, _opts) do
    current_user = current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
