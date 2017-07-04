defmodule CoursePlanner.ClassView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.{OfferedCourse, Repo}
  alias Ecto.Changeset

  def offered_courses_to_select do
    OfferedCourse
    |> Repo.all()
    |> Repo.preload([:course, :term])
    |> Enum.map(&offered_course_to_select/1)
  end

  def offered_course_to_select(offered_course) do
    {offered_course_name(offered_course), offered_course.id}
  end

  def offered_course_name(offered_course) do
    Enum.join([offered_course.term.name, offered_course.course.name], " - ")
  end

  def selected_offered_course(changeset) do
    Changeset.get_field(changeset, :offered_course_id)
  end

  def page_title do
    "Classes"
  end
end
