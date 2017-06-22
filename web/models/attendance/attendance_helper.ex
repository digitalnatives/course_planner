defmodule CoursePlanner.AttendanceHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, OfferedCourse, Attendance}
  alias Ecto.{Multi, DateTime}

  def get_course_attendances(offered_course_id) do
    Repo.one(from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: a in assoc(c,  :attendances),
      join: as in assoc(a, :student),
      join: ac in assoc(a, :class),
      preload: [:term, :course, :teachers, :students],
      preload: [classes: {c, attendances: {a, student: as, class: ac}}],
      where: oc.id == ^offered_course_id,
      order_by: [asc: c.date])
  end

  def get_teacher_course_attendances(offered_course_id, teacher_id) do
    Repo.one(from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: a in assoc(c,  :attendances),
      preload: [:term, :course, teachers: t, students: s],
      preload: [classes: {c, attendances: a}],
      where: oc.id == ^offered_course_id and t.id == ^teacher_id,
      order_by: [asc: c.date])
  end

  def get_student_attendances(offered_course_id, student_id) do
    Repo.all(from a in Attendance,
      join: s in assoc(a, :student),
      join: c in assoc(a,  :class),
      join: oc in assoc(c, :offered_course),
      preload: [class: {c, [offered_course: {oc, [:course, :term]}]}, student: s],
      where: a.student_id == ^student_id and oc.id == ^offered_course_id,
      order_by: [asc: c.date])
  end

  def get_all_offered_courses do
    Repo.all(from oc in OfferedCourse,
      join: c in assoc(oc, :classes),
      join: s in assoc(oc, :students),
      join: t in assoc(oc, :teachers),
      preload: [:term, :course, teachers: t, students: s, classes: c])
  end

  def get_all_teacher_offered_courses(teacher_id) do
    Repo.all(from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      join: c in assoc(oc, :classes),
      join: s in assoc(oc, :students),
      preload: [:term, :course, teachers: t, students: s, classes: c],
      where: t.id == ^teacher_id)
  end

  def get_all_student_offered_courses(student_id) do
    Repo.all(from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: t in assoc(oc, :teachers),
      preload: [:term, :course, teachers: t, students: s, classes: c],
      where: s.id == ^student_id)
  end

  def update_multiple_attendances(attendance_changeset_list) do
    multi = Multi.new

    updated_multi =
      attendance_changeset_list
      |> Enum.reduce(multi, fn(attendance_changeset, operation_list) ->
           operation_atom =
             attendance_changeset.data.id
             |> Integer.to_string()
             |> String.to_atom()

           Multi.update(operation_list, operation_atom, attendance_changeset)
         end)

    Repo.transaction(updated_multi)
  end

  def update_class_attendance_records(offered_course_id) do
    query = from oc in OfferedCourse,
    join: s in assoc(oc, :students),
    join: c in assoc(oc, :classes),
    join: cs in assoc(c, :students),
    preload: [students: s, classes: {c, students: cs}]

    offered_course_with_classes     = Repo.get(query, offered_course_id)
    offered_course_with_attendances = get_course_attendances(offered_course_id)

    cond do
      is_nil(offered_course_with_attendances) && is_nil(offered_course_with_classes) ->
        {:ok, nil}
      is_nil(offered_course_with_attendances) ->
        Enum.map(offered_course_with_attendances.classes, fn(class) ->
          create_class_attendance_records(class)
        end)
      true ->
        offered_course_with_attendances
        |> get_incorrect_attendance_record()
        |> fix_incorrect_attendance_record()
    end
  end

  defp get_incorrect_attendance_record(offered_course) do
    offered_course_classes = offered_course.classes

    Enum.map(offered_course_classes, fn(class) ->
      missing_students =
        Enum.filter(offered_course.students, fn(student) ->
          not Enum.any?(class.attendances, fn(attendance) ->
                attendance.student.id == student.id
              end)
        end)

        excessive_attendances =
          Enum.filter(class.attendances, fn(attendance) ->
            not Enum.any?(offered_course.students, fn(student) ->
                  attendance.student.id == student.id
                end)
          end)

        %{
          class_id: class.id,
          missing_students: missing_students,
          excessive_attendances: excessive_attendances
         }
    end)
  end

  defp fix_incorrect_attendance_record(incorrect_records)
    when is_list(incorrect_records) do
      attendances_data =
        Enum.flat_map(incorrect_records,
          fn(%{missing_students: students, class_id: class_id, excessive_attendances: _}) ->
            students
            |> Enum.map(fn(student) ->
                 [
                   class_id: class_id,
                   student_id: student.id,
                   attendance_type: "Not filled",
                   inserted_at: DateTime.utc(),
                   updated_at: DateTime.utc()
                 ]
               end)
        end)

      multi =
        Multi.new
        |>  Multi.insert_all(:attendances, Attendance, attendances_data)

      multi =
        Enum.reduce(incorrect_records, multi, fn(item, class_multi) ->
            Enum.reduce(item.excessive_attendances, class_multi,
            fn(excessive_attendance, attendance_multi) ->
              Multi.delete(attendance_multi, :"delete_#{excessive_attendance.id}", excessive_attendance)
            end)
        end)

      Repo.transaction(multi)
  end

  def create_class_attendance_records(class) do
    students = class.students

    if is_nil(students) do
      {:ok, nil}
    else
      attendances_data =
        students
        |> Enum.map(fn(student) ->
             [
               class_id: class.id,
               student_id: student.id,
               attendance_type: "Not filled",
               inserted_at: DateTime.utc(),
               updated_at: DateTime.utc()
             ]
           end)

      Multi.new
      |>  Multi.insert_all(:attendances, Attendance, attendances_data)
      |> Repo.transaction()
    end
  end
end
