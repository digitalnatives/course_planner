defmodule CoursePlanner.CalendarController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.CalenderHelper

  def index(%{assigns: %{current_user: current_user}} = conn, params) do
    changeset = CalenderHelper.validate(params)

    case changeset.valid? do
     true ->
       my_classes = Map.get(changeset.changes, :my_classes) || false
       date = Map.get(changeset.changes, :date) || Date.utc_today()

       week_range =  CalenderHelper.get_week_range(date)
       offered_courses = CalenderHelper.get_user_classes(current_user, my_classes, week_range)
       render conn, "index.json", offered_courses: offered_courses
     false ->
       conn
       |> Map.put(:errors, changeset.errors)
       |> put_status(406)
       |> render(CoursePlanner.ErrorView, "406.json")
    end
  end
end
