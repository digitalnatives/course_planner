defmodule CoursePlanner.OfferedCourseView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.{CourseHelper, Terms}
  alias Ecto.Changeset

  def terms_to_select do
    Terms.all()
    |> Enum.map(&{&1.name, &1.id})
  end

  def selected_term(changeset) do
    Changeset.get_field(changeset, :term_id)
  end

  def courses_to_select do
    CourseHelper.all_none_deleted()
    |> Enum.map(&{&1.name, &1.id})
  end

  def selected_course(changeset) do
    Changeset.get_field(changeset, :course_id)
  end
end
