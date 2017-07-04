defmodule CoursePlanner.OfferedCourseView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.{Repo, Teachers, Terms, Students, Course, SharedView}
  alias Ecto.Changeset

  def terms_to_select do
    Terms.all()
    |> Enum.map(&{&1.name, &1.id})
  end

  def selected_term(changeset) do
    Changeset.get_field(changeset, :term_id)
  end

  def courses_to_select do
    Course
    |> Repo.all()
    |> Enum.map(&{&1.name, &1.id})
  end

  def selected_course(changeset) do
    Changeset.get_field(changeset, :course_id)
  end

  def students_to_select do
    Students.all()
    |> Enum.map(
        fn student ->
          full_name =
            [student.name, student.family_name, student.nickname && "(#{student.nickname})"]
            |> Enum.filter(fn v -> String.length(to_string v) > 0 end)
            |> Enum.join(" ")

          %{
            value: student.id,
            label: full_name,
            image: SharedView.get_gravatar_url(student.email)
          }
        end
      )
  end

  def selected_students(changeset) do
    changeset
    |> Changeset.get_field(:students)
    |> Enum.map(&(&1.id))
  end

  def teachers_to_select do
    Teachers.all()
    |> Enum.map(
        fn teacher ->
          full_name =
            [teacher.name, teacher.family_name, teacher.nickname && "(#{teacher.nickname})"]
            |> Enum.filter(fn v -> String.length(to_string v) > 0 end)
            |> Enum.join(" ")

          %{
            value: teacher.id,
            label: full_name,
            image: SharedView.get_gravatar_url(teacher.email)
          }
        end
      )
  end

  def selected_teachers(changeset) do
    changeset
    |> Changeset.get_field(:teachers)
    |> Enum.map(&(&1.id))
  end

  def page_title do
    "Offered courses"
  end
end
