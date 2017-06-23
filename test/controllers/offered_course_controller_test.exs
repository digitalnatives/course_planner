defmodule CoursePlanner.OfferedCourseControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.{Course, OfferedCourse, Repo, Terms}
  import CoursePlanner.Factory

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
    user = build(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  @tag user_role: :coordinator
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 200) =~ "Offered courses"
  end

  @tag user_role: :coordinator
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :new)
    assert html_response(conn, 200) =~ "New offered course"
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
    assert html_response(conn, 200) =~ "New offered course"
  end

  @tag user_role: :coordinator
  test "shows chosen resource", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 200) =~ "Show offered course"
  end

  @tag user_role: :coordinator
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, offered_course_path(conn, :show, -1)
    end
  end

  @tag user_role: :coordinator
  test "renders form for editing chosen resource", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :edit, offered_course)
    assert html_response(conn, 200) =~ "Edit offered course"
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
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: invalid_attrs()
    assert html_response(conn, 200) =~ "Edit offered course"
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
    assert html_response(conn, 200) =~ "New offered course"
  end

  @tag user_role: :coordinator
  test "does not create resource and renders errors when data number_of_sessions is zero", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: %{attrs | number_of_sessions: 0}
    assert html_response(conn, 200) =~ "New offered course"
  end

  @tag user_role: :coordinator
  test "does not create resource and renders errors when data number_of_sessions is too big", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: %{attrs | number_of_sessions: 100_000_000}
    assert html_response(conn, 200) =~ "New offered course"
  end

  @tag user_role: :teacher
  test "teacher can see offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 200) =~ "Show offered course"
  end

  @tag user_role: :teacher
  test "teacher can edit offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :edit, offered_course)
    assert html_response(conn, 200) =~ "Edit offered course"
  end

  @tag user_role: :teacher
  test "teacher can update offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    params = %{syllabus: "New syllabus"}
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
    assert redirected_to(conn) == offered_course_path(conn, :show, offered_course)
    assert Repo.get_by(OfferedCourse, params)
  end

  @tag user_role: :teacher
  test "teacher can't list all offered courses", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 403)
  end

  @tag user_role: :teacher
  test "teacher can't see form for new offered course", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :new)
    assert html_response(conn, 403)
  end

  @tag user_role: :teacher
  test "teacher can't create offered course", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: attrs
    assert html_response(conn, 403)
  end

  @tag user_role: :teacher
  test "teacher can't delete offered course", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = delete conn, offered_course_path(conn, :delete, offered_course)
    assert html_response(conn, 403)
  end

  @tag user_role: :student
  test "student can see offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 200) =~ "Show offered course"
  end

  @tag user_role: :student
  test "student can't edit offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :edit, offered_course)
    assert html_response(conn, 403)
  end

  @tag user_role: :student
  test "student can't update offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    params = %{syllabus: "New syllabus"}
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
    assert html_response(conn, 403)
  end

  @tag user_role: :student
  test "student can't list all offered courses", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 403)
  end

  @tag user_role: :student
  test "student can't see form for new offered course", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :new)
    assert html_response(conn, 403)
  end

  @tag user_role: :student
  test "student can't create offered course", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: attrs
    assert html_response(conn, 403)
  end

  @tag user_role: :student
  test "student can't delete offered course", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = delete conn, offered_course_path(conn, :delete, offered_course)
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't see offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :show, offered_course)
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't edit offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    conn = get conn, offered_course_path(conn, :edit, offered_course)
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't update offered course", %{conn: conn} do
    offered_course = insert(:offered_course)
    params = %{syllabus: "New syllabus"}
    conn = put conn, offered_course_path(conn, :update, offered_course), offered_course: params
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't list all offered courses", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :index)
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't see form for new offered course", %{conn: conn} do
    conn = get conn, offered_course_path(conn, :new)
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't create offered course", %{conn: conn} do
    attrs = valid_attrs()
    conn = post conn, offered_course_path(conn, :create), offered_course: attrs
    assert html_response(conn, 403)
  end

  @tag user_role: :volunteer
  test "volunteer can't delete offered course", %{conn: conn} do
    offered_course = Repo.insert! %OfferedCourse{term_id: term().id, course_id: course("Course2").id}
    conn = delete conn, offered_course_path(conn, :delete, offered_course)
    assert html_response(conn, 403)
  end
end
