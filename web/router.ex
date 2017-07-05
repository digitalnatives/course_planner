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
    pipe_through :protected

    get "/", PageController, :index

    resources "/dashboard", DashboardController, only: [:show], singleton: true

    resources "/users", UserController, except: [:create, :new, :show]
    resources "/coordinators", CoordinatorController
    resources "/students", StudentController
    resources "/teachers", TeacherController
    resources "/volunteers", VolunteerController

    resources "/courses", CourseController
    resources "/terms", TermController do
      get "/course_matrix", CourseMatrixController, :index, as: :course_matrix
    end
    resources "/offered_courses", OfferedCourseController
    resources "/classes", ClassController, except: [:show]
    resources "/tasks", TaskController do
      post "/grab", TaskController, :grab, as: :grab
    end

    resources "/attendances", AttendanceController, only: [:index, :show] do
      get "/fill_course", AttendanceController, :fill_course, as: :fill_course
      put "/update_fill", AttendanceController, :update_fill, as: :update_fill
    end
  end

  if Mix.env == :dev do
    scope "/dev" do
      pipe_through [:browser]

      forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
    end
  end
end
