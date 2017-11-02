defmodule CoursePlanner.OfferedCourseControllerTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlanner.{Courses.Course, Courses.OfferedCourse, Repo, Terms, Attendances.Attendance}
  import CoursePlanner.Factory

  setup do
    insert(:system_variable, %{key: "TIMEZONE", value: "Europe/Budapest", type: "timezone"})
    :ok
  end

  def valid_attrs do
    %{
      term_id: term().id,
      course_id: course("Course1").id,
      number_of_sessions: 20,
      syllabus: "some syllabus"
    }
  end

  def invalid_attrs do
    %{course_id: -1}
  end

  defp term do
    {:ok, term} = Terms.create(
      %{
        name: "Name",
        start_date: "2017-01-01",
        end_date: "2017-01-31",
        minimum_teaching_days: 5,
        status: "Active"
      })
    term
  end

  defp course(name) do
    Repo.insert!(
      Course.changeset(
        %Course{},
        %{
          name: name,
          description: "Description"
        }))
  end

  setup(%{user_role: role}) do
    conn =
      role
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  @tag user_role: :coordinator
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 200) =~ "Courses"
  end

  @tag user_role: :supervisor
  test "lists all entries on index for supervisor", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 200) =~ "Courses"
  end

  @tag user_role: :coordinator
  test "renders form for new resources", %{conn: conn} do
    insert_list(3, :student)
    conn = get conn, offered_course_path(conn, :new)
    assert html_response(conn, 200) =~ "New course"
  end

  @tag user_role: :coordinator
  test "creates resource and redirects when data is valid", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: attrs
    assert redirected_to(conn) == offered_course_path(conn, :index)
    assert Repo.get_by(OfferedCourse, attrs)
  end

  @tag user_role: :coordinator
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, offered_course_path(conn, :create), offered_course: invalid_attrs()
    assert html_response(conn, 200) =~ "New course"
  end

  @tag user_role: :coordinator
  test "shows chosen resource", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 200) =~ "#{offered_course.course.name} - #{offered_course.term.name}"
  end

  @tag user_role: :supervisor
  test "shows chosen resource for supervisor", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 200) =~ "#{offered_course.course.name} - #{offered_course.term.name}"
  end

  @tag user_role: :coordinator
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, offered_course_path(conn, :show, -1)
    end
  end

  @tag user_role: :supervisor
  test "renders page not found when id is nonexistent for supervisor", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :show, -1)
    assert html_response(conn, 403)
  end

  @tag user_role: :coordinator
  test "renders form for editing chosen resource", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :edit, offered_course)
    assert html_response(conn, 200) =~ "Edit course"
  end

  @tag user_role: :coordinator
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    offered_course = insert(:offered_course)
    attrs = valid_attrs()
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: attrs
    assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
    assert Repo.get_by(OfferedCourse, attrs)
  end

  @tag user_role: :coordinator
  test "creates missing attendances when students added to the course", %{conn: conn} do
    current_student = insert(:student)
    offered_course = insert(:offered_course, students: [current_student])
    class = insert(:class, offered_course: offered_course)
    insert(:attendance, %{class: class, student: current_student})

    new_students = insert_list(3, :student)
    all_student_ids =
      [current_student | new_students]
      |> Enum.map(fn(student) ->  student.id end)

    attrs =
       %{
          student_ids: all_student_ids
        }
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: attrs
    assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
    assert length(Repo.all(Attendance)) == 4
  end

  @tag user_role: :coordinator
  test "deletes excessive attendances when students is removed from offered_course", %{conn: conn} do
    current_students = insert_list(3, :student)
    offered_course = insert(:offered_course, students: current_students)
    class = insert(:class, offered_course: offered_course)

    Enum.map(current_students, fn(student) ->
      insert(:attendance, %{class: class, student: student})
    end)

    new_student = insert(:student)

    attrs =
       %{
          student_ids: [new_student.id]
        }
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: attrs
    assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
    assert length(Repo.all(Attendance)) == 1
  end

  @tag user_role: :coordinator
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: invalid_attrs()
    assert html_response(conn, 200) =~ "Edit course"
  end

  @tag user_role: :coordinator
  test "deletes chosen resource", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = delete conn, offered_course_path(conn, :delete, offered_course)
    assert redirected_to(conn) == offered_course_path(conn, :index)
    refute Repo.get(OfferedCourse, offered_course.id)
  end

  @tag user_role: :coordinator
  test "does not create an offered_course if already is done in the requested term", %{conn: conn} do
    course = insert(:course)
    term = insert(:term)
    insert(:offered_course, %{term: term, course: course})
    offered_course_duplicate_attrs =
      %{
        term_id: term.id,
        course_id: course.id,
        number_of_sessions: 10,
        syllabus: "some syllabus"
      }

    conn = post conn, offered_course_path(conn, :create), offered_course: offered_course_duplicate_attrs
    assert html_response(conn, 200) =~ "This course is already offered in this term"
  end

  @tag user_role: :coordinator
  test "does not create resource and renders errors when data number_of_sessions is negative", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: %{attrs | number_of_sessions: -1}
    assert html_response(conn, 200) =~ "New course"
  end

  @tag user_role: :coordinator
  test "does not create resource and renders errors when data number_of_sessions is zero", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: %{attrs | number_of_sessions: 0}
    assert html_response(conn, 200) =~ "New course"
  end

  @tag user_role: :coordinator
  test "does not create resource and renders errors when data number_of_sessions is too big", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: %{attrs | number_of_sessions: 100_000_000}
    assert html_response(conn, 200) =~ "New course"
  end

  describe "teacher" do
    @tag user_role: :teacher
    test "can see offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :show, offered_course)
      assert html_response(conn, 200) =~ "#{offered_course.course.name} - #{offered_course.term.name}"
    end

    @tag user_role: :teacher
    test "can edit offered course if assigned to her", %{conn: conn} do
      teacher = conn.assigns.current_user
      offered_course = insert(:offered_course, teachers: [teacher])
      conn = get conn, offered_course_path(conn, :edit, offered_course)
      assert html_response(conn, 200) =~ "Edit course"
    end

    @tag user_role: :teacher
    test "cannot edit offered course if is not assigned to her", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :edit, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "can update offered course if assigned to her", %{conn: conn} do
      teacher = conn.assigns.current_user
      offered_course = insert(:offered_course, teachers: [teacher])
      params = %{syllabus: "New syllabus"}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
      assert Repo.get_by(OfferedCourse, params)
    end

    @tag user_role: :teacher
    test "can not update offered syllabus course if is not assigned to her", %{conn: conn} do
      offered_course = insert(:offered_course)
      params = %{syllabus: "New syllabus"}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "can not update anything beside syllabus", %{conn: conn} do
      teacher = conn.assigns.current_user
      offered_course = insert(:offered_course, teachers: [teacher])
      params = %{syllabus: "New syllabus", term: nil, course: nil, number_of_sessions: -1}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
      updated_offered_course = Repo.get!(OfferedCourse, offered_course.id)

      assert "New syllabus" == updated_offered_course.syllabus
      assert offered_course.course_id == updated_offered_course.course_id
      assert offered_course.term_id == updated_offered_course.term_id
      assert offered_course.number_of_sessions == updated_offered_course.number_of_sessions
    end

    @tag user_role: :teacher
    test "can not update if syllabus is empty", %{conn: conn} do
      teacher = conn.assigns.current_user
      offered_course = insert(:offered_course, teachers: [teacher])
      params = %{syllabus: ""}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert html_response(conn, 200) =~ "Edit course"
    end

    @tag user_role: :teacher
    test "can list their offered courses", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :index)
      assert html_response(conn, 200)
    end

    @tag user_role: :teacher
    test "can't see form for new offered course", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :new)
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "can't create offered course", %{conn: conn} do
      attrs = valid_attrs()
      conn = post conn, offered_course_path(conn, :create), offered_course: attrs
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "can't delete offered course", %{conn: conn} do
      offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
      conn = delete conn, offered_course_path(conn, :delete, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "can't see new course button", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :index)
      refute html_response(conn, 200) =~ "New course"
    end
  end

  describe "student" do
    @tag user_role: :student
    test "can see offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :show, offered_course)
      assert html_response(conn, 200) =~ "#{offered_course.course.name} - #{offered_course.term.name}"
    end

    @tag user_role: :student
    test "can't edit offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :edit, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :student
    test "can't update offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      params = %{syllabus: "New syllabus"}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert html_response(conn, 403)
    end

    @tag user_role: :student
    test "can list their offered courses", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :index)
      assert html_response(conn, 200)
    end

    @tag user_role: :student
    test "can't see form for new offered course", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :new)
      assert html_response(conn, 403)
    end

    @tag user_role: :student
    test "can't create offered course", %{conn: conn} do
      attrs = valid_attrs()
      conn = post conn, offered_course_path(conn, :create), offered_course: attrs
      assert html_response(conn, 403)
    end

    @tag user_role: :student
    test "can't delete offered course", %{conn: conn} do
      offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
      conn = delete conn, offered_course_path(conn, :delete, offered_course)
      assert html_response(conn, 403)
    end
  end

  describe "volunteer" do
    @tag user_role: :volunteer
    test "can't see offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :show, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "can't edit offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :edit, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "can't update offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      params = %{syllabus: "New syllabus"}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "can't list all offered courses", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :index)
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "can't see form for new offered course", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :new)
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "can't create offered course", %{conn: conn} do
      attrs = valid_attrs()
      conn = post conn, offered_course_path(conn, :create), offered_course: attrs
      assert html_response(conn, 403)
    end

    @tag user_role: :volunteer
    test "can't delete offered course", %{conn: conn} do
      offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
      conn = delete conn, offered_course_path(conn, :delete, offered_course)
      assert html_response(conn, 403)
    end
  end

  describe "supervisor" do
    @tag user_role: :supervisor
    test "can see offered course", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :show, offered_course)
      assert html_response(conn, 200) =~ "#{offered_course.course.name} - #{offered_course.term.name}"
    end

    @tag user_role: :supervisor
    test "can't edit offered course if assigned to her", %{conn: conn} do
      teacher = conn.assigns.current_user
      offered_course = insert(:offered_course, teachers: [teacher])
      conn = get conn, offered_course_path(conn, :edit, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :teacher
    test "cannot edit offered course if is not assigned to her", %{conn: conn} do
      offered_course = insert(:offered_course)
      conn = get conn, offered_course_path(conn, :edit, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :supervisor
    test "can't update offered course", %{conn: conn} do
      teacher = conn.assigns.current_user
      offered_course = insert(:offered_course, teachers: [teacher])
      params = %{syllabus: "New syllabus"}
      conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
      assert html_response(conn, 403)
    end

    @tag user_role: :supervisor
    test "can list offered courses", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :index)
      assert html_response(conn, 200)
    end

    @tag user_role: :supervisor
    test "can't see form for new offered course", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :new)
      assert html_response(conn, 403)
    end

    @tag user_role: :supervisor
    test "can't create offered course", %{conn: conn} do
      attrs = valid_attrs()
      conn = post conn, offered_course_path(conn, :create), offered_course: attrs
      assert html_response(conn, 403)
    end

    @tag user_role: :supervisor
    test "can't delete offered course", %{conn: conn} do
      offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
      conn = delete conn, offered_course_path(conn, :delete, offered_course)
      assert html_response(conn, 403)
    end

    @tag user_role: :supervisor
    test "can't see new course button", %{conn: conn} do
      conn = get conn, offered_course_path(conn, :index)
      refute html_response(conn, 200) =~ "New course"
    end
  end
end
