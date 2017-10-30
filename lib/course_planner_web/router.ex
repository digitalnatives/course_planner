defmodule CoursePlannerWeb.Router do
  @moduledoc false
  use CoursePlannerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected_api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug CoursePlanner.CurrentUser
  end

  pipeline :public_api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :with_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug CoursePlanner.CurrentUser
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated,
         handler: CoursePlanner.Auth.GuardianErrorHandler
  end

  scope "/api/v1" do
    pipe_through :public_api

    resources "/sessions", CoursePlannerWeb.Auth.Api.JsonSessionController,
      only: [:create]
  end

  scope "/" do
    pipe_through :browser
    resources "/sessions", CoursePlannerWeb.Auth.SessionController,
      only: [:new, :create, :delete]
    resources "/passwords", CoursePlannerWeb.Auth.PasswordController,
      only: [:new, :create, :edit, :update]
  end

  scope "/", CoursePlannerWeb do
    pipe_through [:protected_api]

    resources "/calendar", CalendarController, only: [:show], singleton: true
  end

  scope "/", CoursePlannerWeb do
    pipe_through [:browser, :with_session, :login_required]

    get "/", PageController, :index

    resources "/dashboard", DashboardController, only: [:show], singleton: true
    resources "/schedule", ScheduleController, only: [:show], singleton: true

    resources "/users", UserController, except: [:create, :new]
    post "/notify", UserController, :notify
    put "/resend_email/:id", UserController, :resend_email

    resources "/bulk", BulkController, only: [:new, :create], singleton: true

    resources "/coordinators", CoordinatorController
    resources "/students", StudentController
    resources "/teachers", TeacherController
    resources "/volunteers", VolunteerController

    resources "/courses", CourseController, except: [:show]
    resources "/terms", TermController do
      get "/course_matrix", CourseMatrixController, :index, as: :course_matrix
    end
    resources "/offered_courses", OfferedCourseController
    resources "/classes", ClassController, except: [:show]
    resources "/tasks", TaskController do
      post "/grab", TaskController, :grab, as: :grab
      post "/drop", TaskController, :drop, as: :drop
    end

    resources "/attendances", AttendanceController, only: [:index, :show] do
      get "/fill_course", AttendanceController, :fill_course, as: :fill_course
      put "/update_fill", AttendanceController, :update_fill, as: :update_fill
    end

    resources "/settings", SettingController, only: [:show, :edit, :update], singleton: true
    resources "/about", AboutController, only: [:show], singleton: true

    resources "/events", EventController
  end

  if Mix.env == :dev do
    scope "/dev" do
      pipe_through [:browser]

      forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
    end
  end
end
