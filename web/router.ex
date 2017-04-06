defmodule CoursePlanner.Router do
  use CoursePlanner.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CoursePlanner do
    pipe_through :api
  end
end
