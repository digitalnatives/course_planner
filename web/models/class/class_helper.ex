defmodule CoursePlanner.ClassHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, Class, Attendance}
  alias Ecto.DateTime

  def delete(id) do
    class = Repo.get(Class, id)
    if is_nil(class) do
      {:error, :not_found}
    else
      case class.status do
        "Planned" -> hard_delete_class(class)
        _         -> soft_delete_class(class)
      end
    end
  end

  defp soft_delete_class(class) do
    changeset = change(class, %{deleted_at: DateTime.utc()})
    Repo.update(changeset)
  end

  defp hard_delete_class(class) do
    Repo.delete(class)
  end

  def all_none_deleted do
    Repo.all(non_deleted_query())
  end

  def is_class_duration_correct?(class) do
    DateTime.compare(class.starting_at, class.finishes.at) == :lt
      && DateTime.to_erl(class.starting_at) != 0
  end

  defp non_deleted_query do
    from c in Class,
      preload: [{:offered_course, :course}],
      where: is_nil(c.deleted_at),
      order_by: [desc: :date, desc: :starting_at]
  end

  defp get_class_students(offered_course_id) do
    Repo.all(
    from c in Class,
      join: oc in assoc(c, :offered_course),
      join: s in assoc(oc, :students),
      preload: [offered_course: {oc, students: s}],
      where: oc.id == ^offered_course_id
      )
  end

  def create_class_attendance_records(class) do
    class_data = List.first(get_class_students(class.offered_course_id))

    if is_nil(class_data) do
      {:ok, nil}
    else
      class_data.offered_course.students
      |> Enum.map(fn(item) ->
           ch = Attendance.changeset(%Attendance{},
             %{
              class_id: class.id,
              student_id: item.id,
              attendance_type: "Not filled"
             })
           Repo.insert(ch)
         end)
      |> Enum.reduce({:ok, nil}, fn(item, out) ->
           case item do
             {:ok, _ch} ->
               out
             true ->
               item
           end
         end)
    end
  end
end
