defmodule CoursePlanner.Accounts.Teachers do
  @moduledoc false
  import Ecto.Query
  alias CoursePlanner.{Repo, Accounts.User, Accounts.Users, Courses.OfferedCourse}

  @teachers from u in User, where: u.role == "Teacher"

  def all do
    Repo.all(@teachers)
  end

  def query do
    @teachers
  end

  def new(user, token) do
    user
    |> Map.put("role", "Teacher")
    |> Users.new_user(token)
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      teacher ->
        teacher
        |> User.changeset(params, :update)
        |> Repo.update
        |> format_error(teacher)
    end
  end

  defp format_error({:ok, teacher}, _), do: {:ok, teacher}
  defp format_error({:error, changeset}, teacher), do: {:error, teacher, changeset}

  def courses(teacher_id) do
    Repo.all(from oc in OfferedCourse,
      left_join: oct in "offered_courses_teachers", on: oct.offered_course_id == oc.id,
      join: t in assoc(oc, :term),
      preload: [term: t],
      preload: [:course],
      where: oct.teacher_id == ^teacher_id,
      order_by: [desc: t.start_date])
  end

  def can_update_offered_course?(user, offered_course) do
    offered_course.teachers
    |> Enum.any?(fn(teacher) -> teacher.id ==  user.id end)
  end
end
