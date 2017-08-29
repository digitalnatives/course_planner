defmodule CoursePlanner.AttendanceControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory
  alias CoursePlanner.{Attendances.Attendance, Accounts.User}

  @valid_insert_attrs %{offered_course: nil, date: %{day: 17, month: 4, year: 2010}, starting_at: %{hour: 14, min: 0, sec: 0}, finishes_at: %{hour: 15, min: 0, sec: 0}}

  defp create_attendance_with_teacher(students, teachers) do
    offered_course = insert(:offered_course, %{students: students, teachers: teachers})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course}
    class = insert(:class, class_attrs)

    Enum.map(students, fn(student)->
         insert(:attendance, %{class: class, student: student})
       end)

    offered_course
  end

  defp create_attendance(students) do
    offered_course = insert(:offered_course, %{students: students})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course}
    class = insert(:class, class_attrs)

    Enum.map(students, fn(student)->
         insert(:attendance, %{class: class, student: student})
       end)

    offered_course
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  setup do
    insert(:system_variable, %{key: "ATTENDANCE_DESCRIPTIONS", value:  "sick leave, informed beforehand", type: "list"})
    :ok
  end

  test "lists all entries on index for coordinator", %{conn: _conn} do
    user_conn = login_as(:coordinator)
    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 200) =~ "Attendances by courses"
  end

  test "lists all entries on index for teacher", %{conn: _conn} do
    user_conn = login_as(:teacher)
    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 200) =~ "Attendances by courses"
  end

  test "lists all entries on index for student", %{conn: _conn} do
    user_conn = login_as(:student)
    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 200) =~ "Attendances by courses"
  end

  test "do not list anything for volunteer", %{conn: _conn} do
    user_conn = login_as(:volunteer)

    conn = get user_conn, attendance_path(user_conn, :index)
    assert html_response(conn, 403)
  end

  test "shows chosen resource by user coordinator", %{conn: _conn} do
    user_conn = login_as(:coordinator)
    students = insert_list(3, :student)
    offered_course = create_attendance(students)

    conn = get user_conn, attendance_path(user_conn, :show, offered_course.id)
    assert html_response(conn, 200) =~ ~r/Attendances for\s+#{offered_course.course.name}\s+in\s+#{offered_course.term.name}/
  end

  test "shows chosen resource by user teacher", %{conn: _conn} do
    user_conn = login_as(:teacher)
    students = insert_list(3, :student)
    teachers = Repo.get(User, user_conn.assigns.current_user.id)
    offered_course = create_attendance_with_teacher(students, [teachers])

    conn = get user_conn, attendance_path(user_conn, :show, offered_course.id)
    assert html_response(conn, 200) =~ ~r/Attendances for\s+#{offered_course.course.name}\s+in\s+#{offered_course.term.name}/
  end

  test "shows chosen resource by user student", %{conn: _conn} do
    user_conn = login_as(:student)

    student = Repo.get!(User, user_conn.assigns.current_user.id)
    offered_course = create_attendance([student])

    conn = get user_conn, attendance_path(user_conn, :show, offered_course.id)
    assert html_response(conn, 200) =~ ~r/Attendances for\s+#{offered_course.course.name}\s+in\s+#{offered_course.term.name}/
  end

  test "does not show chosen resource by user volunteer", %{conn: _conn} do
    user_conn = login_as(:volunteer)

    attendance = Repo.insert! %Attendance{}

    conn = get user_conn, attendance_path(user_conn, :show, attendance)
    assert html_response(conn, 403)
  end

  test "renders page not found when id is nonexistent", %{conn: _conn} do
    student_conn = login_as(:student)
    teacher_conn = login_as(:teacher)
    coordinator_conn = login_as(:coordinator)

    result_student_conn = get student_conn, attendance_path(student_conn, :show, -1)
    assert html_response(result_student_conn, 404)

    result_teacher_conn = get teacher_conn, attendance_path(teacher_conn, :show, -1)
    assert html_response(result_teacher_conn, 404)

    result_coordinator_conn = get coordinator_conn, attendance_path(coordinator_conn, :show, -1)
    assert html_response(result_coordinator_conn, 404)
  end

  test "do not renders form for editing course attendance if requested by by user volunteer", %{conn: _conn} do
    volunteer_conn = login_as(:volunteer)

    attendance = Repo.insert! %Attendance{}
    conn = get volunteer_conn, attendance_fill_course_path(volunteer_conn, :fill_course, attendance)
    assert html_response(conn, 403)
  end

  test "do not update attendence if requested by user volunteer", %{conn: _conn} do
    volunteer_conn = login_as(:volunteer)

    attendance = Repo.insert! %Attendance{}

    conn = put volunteer_conn, attendance_update_fill_path(volunteer_conn, :update_fill, attendance)
    assert html_response(conn, 403)
  end

  test "do not renders form for editing course attendance if requested by by user student", %{conn: _conn} do
    student_conn = login_as(:student)

    attendance = Repo.insert! %Attendance{}

    conn = get student_conn, attendance_fill_course_path(student_conn, :fill_course, attendance)
    assert html_response(conn, 403)
  end

  test "do not update attendence if requested by user student", %{conn: _conn} do
    student_conn = login_as(:student)

    attendance = Repo.insert! %Attendance{}

    conn = put student_conn, attendance_update_fill_path(student_conn, :update_fill, attendance)
    assert html_response(conn, 403)
  end

  test "renders form for editing course attendance if requested by by user coordinator", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    students = insert_list(3, :student)
    offered_course = create_attendance(students)

    conn = get coordinator_conn,
               attendance_fill_course_path(coordinator_conn, :fill_course, offered_course.id)
    assert html_response(conn, 200) =~ "Fill attendances for #{offered_course.course.name} in #{offered_course.term.name}"
  end

  test "renders form for editing course attendance if requested by by user teacher", %{conn: _conn} do
    teacher_conn = login_as(:teacher)

    students = insert_list(3, :student)
    offered_course = create_attendance(students)

    conn = get teacher_conn,
               attendance_fill_course_path(teacher_conn, :fill_course, offered_course.id)
    assert html_response(conn, 200) =~ "Fill attendances for #{offered_course.course.name} in #{offered_course.term.name}"
  end

  test "Updates attendences if requested by user coordinator", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    students = [insert(:student)]
    offered_course = insert(:offered_course, %{students: students})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course}
    class = insert(:class, class_attrs)

    attendances =
      Enum.map(students, fn(student) ->
           insert(:attendance, %{class: class, student: student})
         end)

    update_param = %{classes: %{"0" => %{attendances: %{"0" => %{
                        attendance_type: "Present", id: List.first(attendances).id}},
                        id: class.id
                        }}}

    conn = put coordinator_conn, attendance_update_fill_path(coordinator_conn, :update_fill,
                                                             offered_course.id,
                                                             offered_course: update_param)
    assert redirected_to(conn) == attendance_path(conn, :show, offered_course.id)
  end

  test "Updates attendences if requested by user teacher", %{conn: _conn} do
    teacher_conn = login_as(:teacher)

    students = insert_list(2, :student)
    offered_course = insert(:offered_course, %{students: students})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course}
    class = insert(:class, class_attrs)

    attendances =
      Enum.map(students, fn(student) ->
           insert(:attendance, %{class: class, student: student})
         end)

    update_param = %{classes: %{"0" => %{id: class.id,
                                         attendances:
                        %{
                          "0" => %{attendance_type: "Absent", id: List.first(attendances).id},
                          "1" => %{attendance_type: "Present", id: List.last(attendances).id}
                         }
                        }}}

    conn = put teacher_conn, attendance_update_fill_path(teacher_conn, :update_fill,
                                                             offered_course.id,
                                                             offered_course: update_param)
    assert redirected_to(conn) == attendance_path(conn, :show, offered_course.id)
  end

  test "does not update attendences if of them fails", %{conn: _conn} do
    coordinator_conn = login_as(:coordinator)

    students = [insert(:student)]
    offered_course = insert(:offered_course, %{students: students})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course}
    class = insert(:class, class_attrs)

    attendances =
      Enum.map(students, fn(student) ->
           insert(:attendance, %{class: class, student: student})
         end)

    update_param = %{classes: %{"0" => %{attendances: %{"0" => %{
                        attendance_type: nil, id: List.first(attendances).id}},
                        id: class.id
                        }}}

    conn = put coordinator_conn, attendance_update_fill_path(coordinator_conn, :update_fill,
                                                             offered_course.id,
                                                             offered_course: update_param)
    assert html_response(conn, 200) =~ "Something went wrong."
  end
end
