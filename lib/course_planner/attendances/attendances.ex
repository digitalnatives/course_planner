defmodule CoursePlanner.Attendances do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  import Ecto.Query

  alias CoursePlanner.{Repo, Courses.OfferedCourse, Attendances.Attendance, Classes}
  alias CoursePlannerWeb.{Endpoint, Router.Helpers}
  alias Ecto.{Multi, DateTime}

  def get_course_attendances(offered_course_id) do
    Repo.one(from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: cs in assoc(c, :students),
      join: a in assoc(c,  :attendances),
      join: as in assoc(a, :student),
      join: ac in assoc(a, :class),
      preload: [:term, :course, :teachers, :students],
      preload: [classes: {c, students: cs, attendances: {a, student: as, class: ac}}],
      where: oc.id == ^offered_course_id,
      order_by: [asc: ac.date, asc: as.name, asc: as.family_name])
  end

  def get_teacher_course_attendances(offered_course_id, teacher_id) do
    Repo.one(from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: cs in assoc(c, :students),
      join: a in assoc(c,  :attendances),
      join: as in assoc(a, :student),
      join: ac in assoc(a, :class),
      preload: [:term, :course, teachers: s, students: t],
      preload: [classes: {c, students: cs, attendances: {a, student: as, class: ac}}],
      where: oc.id == ^offered_course_id and t.id == ^teacher_id,
      order_by: [asc: ac.date, asc: s.name, asc: s.family_name])
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

  def create_class_attendance_records(class_id, students)
    when is_list(students) and length(students) > 0 do
      attendances_data =
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
      Repo.insert_all(Attendance, attendances_data)
  end
  def create_class_attendance_records(_, _), do: {:ok, nil}

  def create_students_attendances(offered_course_id, offered_course_students, updated_students) do
    students = updated_students -- offered_course_students

    offered_course_id
      |> Classes.get_offered_course_classes()
      |> Enum.map(fn(class) ->
        create_class_attendance_records(class.id, students)
      end)
  end

  def remove_students_attendances(offered_course_id, offered_course_students, updated_students) do
    student_ids =
      offered_course_students
      |> Kernel.--(updated_students)
      |> Enum.map(fn(student) ->
        student.id
      end)

    class_ids =
      offered_course_id
        |> Classes.get_offered_course_classes()
        |> Enum.map(fn(class) ->
          class.id
        end)

    delete_query = from a in Attendance,
      where: a.class_id in ^class_ids and a.student_id in ^student_ids

    Repo.delete_all(delete_query)
  end

  def get_offered_course_fill_attendance_path(offered_course_id) do
    Helpers.attendance_fill_course_url Endpoint, :fill_course, offered_course_id
  end
end
