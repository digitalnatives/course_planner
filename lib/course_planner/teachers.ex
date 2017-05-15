defmodule CoursePlanner.Teachers do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query
  alias Ecto.{Changeset, DateTime}
  alias CoursePlanner.{Users, OfferedCourse}

  @teachers from u in User, where: u.role == "Teacher" and is_nil(u.deleted_at)

  def all do
    Repo.all(@teachers)
  end

  def query do
    @teachers
  end

  def new(user, token) do
    user
    |> Users.new_user(token)
    |> Changeset.put_change(:role, "Teacher")
    |> Repo.insert()
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      teacher ->
        teacher
        |> User.changeset(params, :update)
        |> add_timestamps()
        |> Repo.update
        |> format_error(teacher)
    end
  end

  defp add_timestamps(%{changes: %{status: "Active"}} = changeset) do
    Changeset.put_change(changeset, :activated_at, DateTime.utc())
  end

  defp add_timestamps(%{changes: %{status: "Frozen"}} = changeset) do
    Changeset.put_change(changeset, :froze_at, DateTime.utc())
  end

  defp add_timestamps(changeset), do: changeset

  defp format_error({:ok, teacher}, _), do: {:ok, teacher}
  defp format_error({:error, changeset}, teacher), do: {:error, teacher, changeset}

  def courses(teacher_id) do
    Repo.all(from oc in OfferedCourse,
      left_join: oct in "offered_courses_teachers", on: oct.offered_course_id == oc.id,
      left_join: u in User, on: u.id == oct.teacher_id,
      join: t in assoc(oc, :term),
      preload: [term: t],
      preload: [:course],
      where: u.id == ^teacher_id,
      order_by: [desc: t.start_date])
  end
end
