defmodule CoursePlanner.CalendarControllerTest do
  use CoursePlanner.ConnCase

  import CoursePlanner.Factory

  @empty_result %{"classes" => []}

  def create_test_data do
    term = insert(:term, %{name: "term1"})

    course1 = insert(:course, %{name: "english"})
    course2 = insert(:course, %{name: "english"})

    student1 = insert(:student, %{name: "s1", family_name: "sf1", nickname: "sn1"})
    student2 = insert(:student, %{name: "s2", family_name: "sf2", nickname: "sn2"})
    student_with_no_class = insert(:student, %{name: "s3", family_name: "sf3", nickname: "sn3"})

    teacher1 = insert(:teacher, %{name: "t1", family_name: "tf1", nickname: "tn1"})
    teacher2 = insert(:teacher, %{name: "t2", family_name: "tf2", nickname: "tn2"})
    teacher_with_no_class = insert(:teacher, %{name: "t3", family_name: "tf3", nickname: "tn3"})

    offered_course_1 = insert(:offered_course, %{term: term, course: course1, students: [student1], teachers: [teacher1]})
    offered_course_2 = insert(:offered_course, %{term: term, course: course2, students: [student1, student2], teachers: [teacher1, teacher2]})

    classes =
      [
        insert(:class, %{offered_course: offered_course_1, date: "2017-01-01", starting_at: %{hour: 10, min: 0, sec: 0},  finishes_at: %{hour: 12, min: 0, sec: 0}, classroom: "r101"}),
        insert(:class, %{offered_course: offered_course_1, date: "2017-01-02", starting_at: %{hour: 10, min: 0, sec: 0},  finishes_at: %{hour: 12, min: 0, sec: 0}, classroom: "r102"}),
        insert(:class, %{offered_course: offered_course_1, date: "2017-01-03", starting_at: %{hour: 10, min: 0, sec: 0},  finishes_at: %{hour: 12, min: 0, sec: 0}, classroom: "r103"}),
        insert(:class, %{offered_course: offered_course_1, date: "2017-01-04", starting_at: %{hour: 10, min: 0, sec: 0},  finishes_at: %{hour: 12, min: 0, sec: 0}, classroom: "r104"}),
        insert(:class, %{offered_course: offered_course_2, date: "2017-01-05", starting_at: %{hour: 10, min: 0, sec: 0},  finishes_at: %{hour: 12, min: 0, sec: 0}, classroom: "r105"}),
        insert(:class, %{offered_course: offered_course_1, date: to_string(Date.utc_today()), starting_at: %{hour: 10, min: 0, sec: 0},  finishes_at: %{hour: 12, min: 0, sec: 0}, classroom: "r106"})
      ]

    %{term: term,
      courses: [course1, course2],
      classes: classes,
      students: [student1, student2],
      teachers: [teacher1, teacher2],
      offered_course_1: offered_course_1,
      offered_course_2: offered_course_2,
      teacher_with_no_class: teacher_with_no_class,
      student_with_no_class: student_with_no_class}
  end

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  defp login_as(user) do
    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end
  #test "unauthenticated request", %{conn: conn} do
  #  conn = get conn, calendar_path(conn, :index)
  #  IO.inspect conn
  #  assert html_response(conn, 401) =~ "Unauthenticated"
  #end

  describe "tests api with wrongly formatted parameters" do
    @tag user_role: :coordinator
    test "fails when date is not formatted correctly", %{conn: conn} do
      params = %{date: "wrong date format", my_classes: "false"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 406) == %{"error" => [%{"date" => "is invalid"}]}
    end

    @tag user_role: :coordinator
    test "fails when my_classes is not a boolean", %{conn: conn} do
      params = %{date: "2017-01-01", my_classes: "this is not a boolean"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 406) == %{"error" => [%{"my_classes" => "is invalid"}]}
    end

    @tag user_role: :coordinator
    test "fails and shows all errors when both params are not formatted correctly", %{conn: conn} do
      params = %{date: "wrong date format", my_classes: "this is not a boolean"}
      errors = %{"error" => [%{"date" => "is invalid"}, %{"my_classes" => "is invalid"}]}

      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 406) == errors
    end
  end

  describe "tests api basic functionality" do
    @tag user_role: :coordinator
    test "returns nothing when there is no classes on the requested date", %{conn: conn} do
      params = %{date: "2017-01-01", my_classes: "false"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == @empty_result
    end

    @tag user_role: :coordinator
    test "returns classes in the requested week and filter other classes out", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r101",
                          "date" => "2017-01-01",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-01", my_classes: "false"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == expected_result
    end

    @tag user_role: :coordinator
    test "returns classes of the current week when date parameter is not present", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r106",
                          "date" => to_string(Date.utc_today()),
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      params = %{my_classes: "false"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == expected_result
    end
  end

  @tag user_role: :coordinator
  test "returns classes in the requested week for coordinator even when my_classes is true", %{conn: conn} do
    create_test_data()

    expected_result =
      %{"classes" => [%{"classroom" => "r101",
                        "date" => "2017-01-01",
                        "finishes_at" => "12:00:00",
                        "starting_at" => "10:00:00",
                        "course_name" => "english",
                        "teachers" => [%{"family_name" => "tf1",
                                         "nickname" => "tn1",
                                         "name" => "t1"}],
                        "term_name" => "term1"}]}

    params = %{date: "2017-01-01", my_classes: "true"}
    conn = get conn, calendar_path(conn, :index), params
    assert json_response(conn, 200) == expected_result
  end

  @tag user_role: :volunteer
  test "returns classes in the requested week for volunteer even when my_classes is true", %{conn: conn} do
    create_test_data()

    expected_result =
      %{"classes" => [%{"classroom" => "r101",
                        "date" => "2017-01-01",
                        "finishes_at" => "12:00:00",
                        "starting_at" => "10:00:00",
                        "course_name" => "english",
                        "teachers" => [%{"family_name" => "tf1",
                                         "nickname" => "tn1",
                                         "name" => "t1"}],
                        "term_name" => "term1"}]}

    params = %{date: "2017-01-01", my_classes: "true"}
    conn = get conn, calendar_path(conn, :index), params
    assert json_response(conn, 200) == expected_result
  end

  describe "when requested by a teacher calendar returns:" do
    @tag user_role: :teacher
    test "empty if the teacher has no class in the requested week", %{conn: _conn} do
      test_data = create_test_data()
      teacher_conn = login_as( test_data.teacher_with_no_class )

      params = %{date: "2017-01-01", my_classes: "true"}
      conn = get teacher_conn, calendar_path(teacher_conn, :index), params
      assert json_response(conn, 200) == @empty_result
    end

    @tag user_role: :teacher
    test "all classes of the current week when not date nor my_classes are present", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r106",
                          "date" => to_string(Date.utc_today()),
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      conn = get conn, calendar_path(conn, :index)
      assert json_response(conn, 200) == expected_result
    end

    @tag user_role: :teacher
    test "all classes for teacher when my_classes parameter is not present", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r101",
                          "date" => "2017-01-01",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-01"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == expected_result
    end

    @tag user_role: :teacher
    test "all classes for teacher when my_classes parameter is false", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r101",
                          "date" => "2017-01-01",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-01", my_classes: "false"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == expected_result
    end

    @tag user_role: :teacher
    test "teaching classes when my_classes parameter is true", %{conn: _conn} do
      test_data = create_test_data()
      teacher = List.last(test_data.teachers)
      teacher_conn = login_as(teacher)

      expected_result =
        %{"classes" => [%{"classroom" => "r105",
                          "date" => "2017-01-05",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => teacher.family_name,
                                           "nickname" => teacher.nickname,
                                           "name" => teacher.name}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-05", my_classes: "true"}
      conn = get teacher_conn, calendar_path(teacher_conn, :index), params
      assert json_response(conn, 200) == expected_result
    end
  end

  describe "when requested by a student calendar returns:" do
    @tag user_role: :student
    test "empty when no class in the requested week", %{conn: _conn} do
      test_data = create_test_data()
      student_conn = login_as( test_data.student_with_no_class )

      params = %{date: "2017-01-01", my_classes: "true"}
      conn = get student_conn, calendar_path(student_conn, :index), params
      assert json_response(conn, 200) == @empty_result
    end

    @tag user_role: :student
    test "all classes when my_classes parameter is not present", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r101",
                          "date" => "2017-01-01",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-01"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == expected_result
    end

    @tag user_role: :student
    test "all classes for student when my_classes parameter is false", %{conn: conn} do
      create_test_data()

      expected_result =
        %{"classes" => [%{"classroom" => "r101",
                          "date" => "2017-01-01",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-01", my_classes: "false"}
      conn = get conn, calendar_path(conn, :index), params
      assert json_response(conn, 200) == expected_result
    end

    @tag user_role: :student
    test "attending classes when my_classes parameter is true", %{conn: _conn} do
      test_data = create_test_data()
      student = List.last(test_data.students)
      studen_conn = login_as(student)

      expected_result =
        %{"classes" => [%{"classroom" => "r105",
                          "date" => "2017-01-05",
                          "finishes_at" => "12:00:00",
                          "starting_at" => "10:00:00",
                          "course_name" => "english",
                          "teachers" => [%{"family_name" => "tf1",
                                           "nickname" => "tn1",
                                           "name" => "t1"},
                                         %{"family_name" => "tf2",
                                            "nickname" => "tn2",
                                            "name" => "t2"}],
                          "term_name" => "term1"}]}

      params = %{date: "2017-01-05", my_classes: "true"}
      conn = get studen_conn, calendar_path(studen_conn, :index), params
      assert json_response(conn, 200) == expected_result
    end
  end
end
