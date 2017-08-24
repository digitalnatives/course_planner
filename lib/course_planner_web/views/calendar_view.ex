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
      starting_at: class.starting_at,
      finishes_at: class.finishes_at,
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
end
