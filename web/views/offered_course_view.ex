defmodule CoursePlanner.OfferedCourseView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.{CourseHelper, Terms, Students}
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

  def students_to_select do
    Students.all()
    |> Enum.map(&{"#{&1.name} #{&1.family_name}", &1.id})
  end

  def selected_students(changeset) do
    changeset
    |> Changeset.get_field(:students)
    |> Enum.map(&(&1.id))
  end
end
