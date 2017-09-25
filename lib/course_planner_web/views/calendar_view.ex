defmodule CoursePlannerWeb.CalendarView do
  @moduledoc false
  use CoursePlannerWeb, :view

  def render("index.json", %{offered_courses: offered_courses}) do
    %{
      classes:
          Enum.flat_map(offered_courses, fn(offered_course) ->
              Enum.map(offered_course.classes, fn(class) -> class_json(offered_course, class) end)
        end)
     }
  end

  def class_json(offered_course, class) do
    %{
      course_name: offered_course.course.name,
      term_name: offered_course.term.name,
      date: class.date,
      starting_at: convert_and_format_time(class.date, class.starting_at),
      finishes_at: convert_and_format_time(class.date, class.finishes_at),
      classroom: class.classroom,
      teachers: Enum.map(offered_course.teachers, &teacher_json/1)
    }
  end

  def teacher_json(teacher) do
    %{
      name: teacher.name,
      family_name: teacher.family_name,
      nickname: teacher.nickname
     }
  end

  defp convert_and_format_time(date, time) do
    date
    |> Ecto.DateTime.from_date_and_time(time)
    |> Settings.utc_to_system_timezone()
    |> Timex.format!("{h24}:{m}:{s}")
  end
end
