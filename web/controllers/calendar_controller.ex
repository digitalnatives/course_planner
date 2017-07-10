defmodule CoursePlanner.CalendarController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.CalendarHelper
  alias Ecto.Changeset

  def show(%{assigns: %{current_user: current_user}} = conn, params) do
    case CalendarHelper.validate(params) do
     %{valid?: true} = changeset ->
       my_classes = Changeset.get_field(changeset, :my_classes, false)
       date = Changeset.get_field(changeset, :date, Date.utc_today())

       week_range =  CalendarHelper.get_week_range(date)
       offered_courses = CalendarHelper.get_user_classes(current_user, my_classes, week_range)
       render conn, "index.json", offered_courses: offered_courses
     %{errors: errors} ->
       formatted_errors = CalendarHelper.format_errors(errors)

       conn
       |> put_status(406)
       |> render(CoursePlanner.ErrorView, "406.json", %{errors: formatted_errors})
    end
  end
end
