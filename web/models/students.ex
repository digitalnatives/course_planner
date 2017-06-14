defmodule CoursePlanner.Students do
  @moduledoc """
    Handle Students specific logics
  """
  alias CoursePlanner.{Repo, User, Users, OfferedCourse}
  import Ecto.Query
  alias Ecto.Changeset

  @students from u in User, where: u.role == "Student"

  def all do
    Repo.all(@students)
  end

  def query do
    @students
  end

  def new(user, token) do
    user
    |> Users.new_user(token)
    |> Changeset.put_change(:role, "Student")
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      student ->
        student
        |> User.changeset(params)
        |> Repo.update
        |> format_error(student)
    end
  end

  defp format_error({:ok, student}, _), do: {:ok, student}
  defp format_error({:error, changeset}, student), do: {:error, student, changeset}

  def courses(student_id) do
    Repo.all(from oc in OfferedCourse,
      left_join: oct in "offered_courses_students", on: oct.offered_course_id == oc.id,
      join: t in assoc(oc, :term),
      preload: [term: t],
      preload: [:course],
      where: oct.student_id == ^student_id,
      order_by: [desc: t.start_date])
  end
end
