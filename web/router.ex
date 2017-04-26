defmodule CoursePlanner.Router do
  use CoursePlanner.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", CoursePlanner do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", CoursePlanner do
    pipe_through :protected

    resources "/users", UserController
    resources "/courses", CourseController
    resources "/terms", TermController, only: [:new, :create, :show, :delete, :edit, :update]
  end

  if Mix.env == :dev do
  scope "/dev" do
    pipe_through [:browser]

    forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
  end
end
end
