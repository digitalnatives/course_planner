defmodule CoursePlanner.Helpers do
  @moduledoc """
  Module with generic helper functions
  """

  alias CoursePlanner.{Repo, Settings.SystemVariable}

  def now_with_timezone do
    timezone = Repo.get_by(SystemVariable, key: "TIMEZONE").value
    Timex.now() |> Timex.to_datetime(timezone)
  end
end
