defmodule CoursePlanner.ClassControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.{Class, Repo, Attendance}
  import CoursePlanner.Factory

  @valid_attrs %{offered_course_id: nil, date: Timex.now(), starting_at: %{hour: 14, min: 0, sec: 0}, finishes_at: %{hour: 15, min: 0, sec: 0}}
  @valid_insert_attrs %{offered_course: nil, date: Timex.now(), starting_at: %{hour: 14, min: 0, sec: 0}, finishes_at: %{hour: 15, min: 0, sec: 0}}
  @invalid_attrs %{}

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
        |> assign(:current_user, insert(:coordinator))
    {:ok, conn: conn}
  end

  defp create_course do
    students = insert_list(3, :student)
    teachers = insert_list(1, :teacher)
    insert(:offered_course, students: students, teachers: teachers)
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, class_path(conn, :index)
    assert html_response(conn, 200) =~ "Classes"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, class_path(conn, :new)
    assert html_response(conn, 200) =~ "New class"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    created_course = create_course()
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert redirected_to(conn) == class_path(conn, :index)
    assert Repo.get_by(Class, completed_attributes)
  end

  test "creates resource fails when no teacher is assigned", %{conn: conn} do
    students = insert_list(3, :student)
    created_course = insert(:offered_course, students: students)
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
    refute Repo.get_by(Class, completed_attributes)
  end

  test "creates resource fails when no student is assigned", %{conn: conn} do
    teachers = [insert(:teacher)]
    created_course = insert(:offered_course, teachers: teachers)
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
    refute Repo.get_by(Class, completed_attributes)
  end

  test "does not create resource and renders errors when data is empty", %{conn: conn} do
    conn = post conn, class_path(conn, :create), class: @invalid_attrs
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when no course", %{conn: conn} do
    conn = post conn, class_path(conn, :create), class: @valid_attrs
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when starting time is zero", %{conn: conn} do
    created_course = create_course()
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id, starting_at: %{hour: 0, min: 0, sec: 0}}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when finishing time is zero", %{conn: conn} do
    created_course = create_course()
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id, finishes_at: %{hour: 0, min: 0, sec: 0}}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when starting time is after finishing time", %{conn: conn} do
    created_course = create_course()
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id, starting_at: %{hour: 12, min: 0, sec: 0},  finishes_at: %{hour: 10, min: 0, sec: 0}}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    created_course = create_course()
    class = Repo.insert! %Class{offered_course_id: created_course.id}
    conn = get conn, class_path(conn, :edit, class)
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert redirected_to(conn) == class_path(conn, :index)
    assert Repo.get_by(Class, update_params)
  end

  test "updates chosen resource time", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id, starting_at: %{hour: 18, min: 0, sec: 0},  finishes_at: %{hour: 19, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert redirected_to(conn) == class_path(conn, :index)
    assert Repo.get_by(Class, update_params)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    created_course = create_course()
    class = Repo.insert! %Class{offered_course_id: created_course.id}
    conn = put conn, class_path(conn, :update, class), class: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if course not selected", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: nil}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if starting time is zero", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id, starting_at: %{hour: 0, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if finishing time is zero", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id, finishes_at: %{hour: 0, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if finishing time is less than starting time", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id, starting_at: %{hour: 2, min: 0, sec: 0}, finishes_at: %{hour: 1, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if finishing time is equal to starting time", %{conn: conn} do
    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id, starting_at: %{hour: 2, min: 0, sec: 0}, finishes_at: %{hour: 2, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "deletes a non-existing id", %{conn: conn} do
    conn = delete conn, class_path(conn, :delete, -1)
    assert html_response(conn, 404)
  end

  test "deletes chosen resource", %{conn: conn} do
    created_course = create_course()
    class_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_args
    conn = delete conn, class_path(conn, :delete, class)
    assert redirected_to(conn) == class_path(conn, :index)
    refute Repo.get(Class, class.id)
  end

  test "creates class and all attendance", %{conn: conn} do
    course = insert(:course)
    term1 = insert(:term, %{
                            start_date: Timex.shift(Timex.now(), months: -2),
                            end_date: Timex.shift(Timex.now(), months: 4),
                            courses: [course]
                           })

    students = insert_list(3, :student)
    teacher = insert(:teacher)
    offered_course = insert(:offered_course, %{term: term1, course: course, students: students, teachers: [teacher]})
    class_attrs = %{@valid_attrs | offered_course_id: offered_course.id}

    conn = post conn, class_path(conn, :create), class: class_attrs
    assert redirected_to(conn) == class_path(conn, :index)
    class = Repo.get_by(Class, class_attrs) |> Repo.preload(:attendances)

    student_ids = students |> Enum.map(&(&1.id)) |> Enum.sort()
    attendance_student_ids = class.attendances |> Enum.map(&(&1.student_id)) |> Enum.sort()

    assert student_ids == attendance_student_ids
  end

  test "deletes class and all attendances of it", %{conn: conn} do
    students = insert_list(3, :student)
    offered_course = insert(:offered_course, %{students: students})
    class_attrs = %{@valid_insert_attrs | offered_course: offered_course}
    class = insert(:class, class_attrs)

    Enum.map(students, fn(student) ->
         insert(:attendance, %{class_id: class.id, student_id: student.id})
       end)

    assert 3 == length(Repo.all(Attendance))
    conn = delete conn, class_path(conn, :delete, class)
    assert redirected_to(conn) == class_path(conn, :index)
    refute Repo.get(Class, class.id)
    assert [] == Repo.all(Attendance)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, class_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, class_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, class_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    created_course = create_course()
    class = Repo.insert! %Class{offered_course_id: created_course.id}

    conn = get student_conn, class_path(student_conn, :edit, class)
    assert html_response(conn, 403)

    conn = get teacher_conn, class_path(teacher_conn, :edit, class)
    assert html_response(conn, 403)

    conn = get volunteer_conn, class_path(volunteer_conn, :edit, class)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    created_course = create_course()
    class_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_args

    conn = delete student_conn, class_path(student_conn, :delete, class.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, class_path(teacher_conn, :delete, class.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, class_path(volunteer_conn, :delete, class.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new class for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, class_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, class_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, class_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create class for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    created_course = create_course()
    completed_attributes = %{@valid_attrs | offered_course_id: created_course.id}

    conn = post student_conn, class_path(student_conn, :create), class: completed_attributes
    assert html_response(conn, 403)

    conn = post teacher_conn, class_path(teacher_conn, :create), class: completed_attributes
    assert html_response(conn, 403)

    conn = post volunteer_conn, class_path(volunteer_conn, :create), class: completed_attributes
    assert html_response(conn, 403)
  end

  test "does not update chosen class for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    created_course = create_course()
    class_insert_args = %Class{offered_course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0})}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | offered_course_id: created_course.id}

    conn = put student_conn, class_path(student_conn, :update, class), class: update_params
    assert html_response(conn, 403)

    conn = put teacher_conn, class_path(teacher_conn, :update, class), class: update_params
    assert html_response(conn, 403)

    conn = put volunteer_conn, class_path(volunteer_conn, :update, class), class: update_params
    assert html_response(conn, 403)
  end

  test "creates resource fails when class date is holiday", %{conn: conn} do
    holiday = build(:holiday, date: %Ecto.Date{day: 1, month: 1, year: 2017})
    course = insert(:course)
    term1 = insert(:term, %{
                            start_date: %Ecto.Date{day: 1, month: 1, year: 2017},
                            end_date: %Ecto.Date{day: 1, month: 6, year: 2017},
                            courses: [course],
                            holidays: [holiday]
                           })

    students = insert_list(3, :student)
    teacher = insert(:teacher)
    offered_course = insert(:offered_course, %{term: term1, course: course, students: students, teachers: [teacher]})

    class_attrs = %{@valid_attrs | date: %{day: 1, month: 1, year: 2017}, offered_course_id: offered_course.id}
    conn = post conn, class_path(conn, :create), class: class_attrs
    assert html_response(conn, 200) =~ "Cannot create a class on holiday"
    refute Repo.get_by(Class, class_attrs)
  end
end
