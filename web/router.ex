defmodule CoursePlanner.Router do
  use CoursePlanner.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CoursePlanner do
    pipe_through :api
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

end
