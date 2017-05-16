defmodule CoursePlanner.TermControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Terms.Term
  alias CoursePlanner.{Course, OfferedCourse , User}

  setup do
    user =
      %User{
        name: "Test User",
        email: "testuser@example.com",
        password: "secret",
        password_confirmation: "secret"
      }

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, term_path(conn, :new)
    assert html_response(conn, 200) =~ "New term"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        status: "Planned"
      }
    conn = post conn, term_path(conn, :create), term: valid_attrs
    assert redirected_to(conn) == term_path(conn, :index)
    assert Repo.get_by(Term, valid_attrs)
  end

  test "creates term with course and redirects when data is valid", %{conn: conn} do
    course = create_course("Course")
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        status: "Planned",
        course_ids: ["#{course.id}"]
      }
    conn = post conn, term_path(conn, :create), term: valid_attrs
    assert redirected_to(conn) == term_path(conn, :index)
    assert %{courses: [%{name: "Course"}]} = (Term |> Repo.get_by(name: "Spring") |> Repo.preload(:courses))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    invalid_attrs =
      %{
        name: nil,
        status: "invalid-status"
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "New term"
  end

  test "show existing term", %{conn: conn} do
    {:ok, t} = CoursePlanner.Terms.create(%{name: "Spring", start_date: "2017-04-25", end_date: "2017-05-25", status: "Planned"})
    conn = get conn, term_path(conn, :show, t.id)
    assert html_response(conn, 200) =~ "Show term"
  end

  test "doesn't show inexisting term", %{conn: conn} do
    conn = get conn, term_path(conn, :show, 1)
    assert html_response(conn, 404)
  end

  test "doesn't show deleted term", %{conn: conn} do
    {:ok, term} = CoursePlanner.Terms.create(%{name: "Spring", start_date: "2017-04-25", end_date: "2017-05-25", status: "Planned"})
    {:ok, _} = CoursePlanner.Terms.delete(term.id)
    conn = get conn, term_path(conn, :show, term.id)
    assert html_response(conn, 404)
  end

  test "soft delete existing term", %{conn: conn} do
    {:ok, t} = CoursePlanner.Terms.create(%{name: "Spring", start_date: "2017-04-25", end_date: "2017-05-25", status: "Planned"})
    conn = delete conn, term_path(conn, :delete, t.id)
    assert redirected_to(conn) == term_path(conn, :index)
    assert Repo.get!(Term, t.id).deleted_at
  end

  test "doesn't delete inexisting term", %{conn: conn} do
    conn = delete conn, term_path(conn, :delete, -1)
    assert html_response(conn, 404)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = get conn, term_path(conn, :edit, term)
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "renders error for editing inexistent resource", %{conn: conn} do
    conn = get conn, term_path(conn, :edit, -1)
    assert html_response(conn, 404)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    term = create_term()
    conn = put conn, term_path(conn, :update, term), term: %{name: "Spring"}
    assert redirected_to(conn) == term_path(conn, :show, term)
    assert Repo.get_by(Term, name: "Spring")
  end

  test "updates term with course and redirects when data is valid", %{conn: conn} do
    course1 = create_course("Course1")
    term = create_term()
    Repo.insert!(%OfferedCourse{term_id: term.id, course_id: course1.id})

    assert %{courses: [%{name: "Course1"}]} = (Term |> Repo.get(term.id) |> Repo.preload(:courses))

    course2 = create_course("Course2")
    conn = put conn, term_path(conn, :update, term), term: %{course_ids: ["#{course2.id}"]}

    assert redirected_to(conn) == term_path(conn, :show, term)
    assert %{courses: [%{name: "Course2"}]} = (Term |> Repo.get(term.id) |> Repo.preload(:courses))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    term = create_term()
    conn = put conn, term_path(conn, :update, term), term: %{name: ""}
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "renders error for updating inexisting resource", %{conn: conn} do
    conn = put conn, term_path(conn, :update, 1), term: %{name: "Fall"}
    assert html_response(conn, 404)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, term_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing terms"
  end

  defp create_term do
    Repo.insert!(
      %Term{
        name: "Fall",
        start_date: %Ecto.Date{day: 1, month: 1, year: 2017},
        end_date: %Ecto.Date{day: 1, month: 6, year: 2017},
        status: "Planned"
      })
  end

  defp create_course(name) do
    Repo.insert!(
      Course.changeset(
        %Course{},
        %{
          name: name,
          description: "Description",
          number_of_sessions: 1,
          session_duration: "01:00:00",
          status: "Active"
        }))
  end
end
