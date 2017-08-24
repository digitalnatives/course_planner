defmodule CoursePlannerWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use CoursePlannerWeb, :controller
      use CoursePlannerWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: CoursePlannerWeb

      alias CoursePlanner.Repo
      import Ecto
      import Ecto.Query

      import CoursePlannerWeb.Router.Helpers
      import CoursePlannerWeb.CustomRoute
      import CoursePlannerWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/course_planner_web/templates",
                        namespace: CoursePlannerWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import CoursePlannerWeb.Router.Helpers
      import CoursePlannerWeb.CustomRoute
      import CoursePlannerWeb.ErrorHelpers
      import CoursePlannerWeb.Gettext

      def page_title, do: "Course Planner"
      defoverridable [page_title: 0]
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias CoursePlanner.Repo
      import Ecto
      import Ecto.Query
      import CoursePlannerWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
