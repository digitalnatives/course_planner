defmodule CoursePlanner.TermControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Terms.Term
  import CoursePlanner.Factory

  setup do
    conn = login_as(:coordinator)
    {:ok, conn: conn}
  end

  defp login_as(user_type) do
    user = insert(user_type)

    Phoenix.ConnTest.build_conn()
    |> assign(:current_user, user)
  end

  test "renders form for new resources for coordinator", %{conn: conn} do
    conn = get conn, term_path(conn, :new)
    assert html_response(conn, 200) =~ "New term"
  end

  test "doesn't render form for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, term_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, term_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, term_path(volunteer_conn, :new)
    assert html_response(conn, 403)
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        holidays:
        %{
          "0" => %{name: "Labor Day 1", date: %{day: 01, month: 05, year: 2010}},
          "1" => %{name: "Labor Day 2", date: %{day: 01, month: 02, year: 2010}}
        }
      }

    conn = post conn, term_path(conn, :create), term: valid_attrs
    assert redirected_to(conn) == term_path(conn, :index)
    assert Repo.get_by(Term, Map.delete(valid_attrs, :holidays))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    invalid_attrs =
      %{
        name: nil
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "New term"
  end

  test "doesn't create resource for forbidden user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = post student_conn, term_path(student_conn, :create), term: %{}
    assert html_response(conn, 403)

    conn = post teacher_conn, term_path(teacher_conn, :create), term: %{}
    assert html_response(conn, 403)

    conn = post volunteer_conn, term_path(volunteer_conn, :create), term: %{}
    assert html_response(conn, 403)
  end

  test "does not create resource and renders errors when holiday is before term start", %{conn: conn} do
    invalid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        holidays:
        %{
          "0" => %{name: "Labor Day 1", date: %{day: 01, month: 5, year: 2008}}
        }
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "is before term"
  end

  test "does not create resource and renders errors when holiday is after term end", %{conn: conn} do
    invalid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        holidays:
        %{
          "0" => %{name: "Labor Day 1", date: %{day: 02, month: 01, year: 2011}}
        }
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "is after term"
  end

  test "show existing term for coordinator", %{conn: conn} do
    t = insert(:term)
    conn = get conn, term_path(conn, :show, t.id)
    assert html_response(conn, 200) =~ "Show term"
  end

  test "doesn't show existing term for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    t = insert(:term)

    conn = get student_conn, term_path(student_conn, :show, t.id)
    assert html_response(conn, 403)

    conn = get teacher_conn, term_path(teacher_conn, :show, t.id)
    assert html_response(conn, 403)

    conn = get volunteer_conn, term_path(volunteer_conn, :show, t.id)
    assert html_response(conn, 403)
  end

  test "doesn't show inexisting term", %{conn: conn} do
    conn = get conn, term_path(conn, :show, 1)
    assert html_response(conn, 404)
  end

  test "delete existing term for coordinator", %{conn: conn} do
    t = insert(:term)
    conn = delete conn, term_path(conn, :delete, t.id)
    assert redirected_to(conn) == term_path(conn, :index)
    refute Repo.get(Term, t.id)
  end

  test "doesn't delete inexisting term", %{conn: conn} do
    conn = delete conn, term_path(conn, :delete, -1)
    assert html_response(conn, 404)
  end

  test "doesn't delete term for forbidden user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    t = insert(:term)

    conn = delete student_conn, term_path(student_conn, :delete, t.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, term_path(teacher_conn, :delete, t.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, term_path(volunteer_conn, :delete, t.id)
    assert html_response(conn, 403)
  end

  test "renders form for editing chosen resource for coordinator", %{conn: conn} do
    term = insert(:term)
    conn = get conn, term_path(conn, :edit, term)
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "doesn't render form for editing for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    term = insert(:term)

    conn = get student_conn, term_path(student_conn, :edit, term)
    assert html_response(conn, 403)

    conn = get teacher_conn, term_path(teacher_conn, :edit, term)
    assert html_response(conn, 403)

    conn = get volunteer_conn, term_path(volunteer_conn, :edit, term)
    assert html_response(conn, 403)
  end

  test "renders error for editing inexistent resource", %{conn: conn} do
    conn = get conn, term_path(conn, :edit, -1)
    assert html_response(conn, 404)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    term = insert(:term)
    conn = put conn, term_path(conn, :update, term), term: %{name: "Spring"}
    assert redirected_to(conn) == term_path(conn, :show, term)
    assert Repo.get_by(Term, name: "Spring")
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    term = insert(:term)
    conn = put conn, term_path(conn, :update, term), term: %{name: ""}
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "doesn't update resource for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    term = insert(:term)

    conn = put student_conn, term_path(student_conn, :update, term), term: %{name: ""}
    assert html_response(conn, 403)

    conn = put teacher_conn, term_path(teacher_conn, :update, term), term: %{name: ""}
    assert html_response(conn, 403)

    conn = put volunteer_conn, term_path(volunteer_conn, :update, term), term: %{name: ""}
    assert html_response(conn, 403)
  end

  test "renders error for updating inexisting resource", %{conn: conn} do
    conn = put conn, term_path(conn, :update, 1), term: %{name: "Fall"}
    assert html_response(conn, 404)
  end

  test "lists all entries on index for coordinator", %{conn: conn} do
    conn = get conn, term_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing terms"
  end

  test "doesn't show index for non coordinator users", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, term_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, term_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, term_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end
end
