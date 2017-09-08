defmodule CoursePlannerWeb.CalendarController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.Classes.Calendars
  alias Ecto.Changeset

  import Canary.Plugs
  plug :authorize_controller

  def show(%{assigns: %{current_user: current_user}} = conn, params) do
    case Calendars.validate(params) do
     %{valid?: true} = changeset ->
       my_classes = Changeset.get_field(changeset, :my_classes, false)
       date = Changeset.get_field(changeset, :date, Date.utc_today())

       week_range =  Calendars.get_week_range(date)
       offered_courses = Calendars.get_user_classes(current_user, my_classes, week_range)
       render conn, "index.json", offered_courses: offered_courses
     %{errors: errors} ->
       formatted_errors = Calendars.format_errors(errors)

       conn
       |> put_status(406)
       |> render(CoursePlannerWeb.ErrorView, "406.json", %{errors: formatted_errors})
    end
  end
end
