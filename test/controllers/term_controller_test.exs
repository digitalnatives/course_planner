defmodule CoursePlanner.TermControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Terms.Term
  alias CoursePlanner.User

  @coordinator %User{
    name: "Test Coordinator",
    email: "testuser@example.com",
    role: "Coordinator"
  }

  @forbidden_user %User{
    name: "Forbidden User",
    role: "Student"
  }

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, @coordinator)
    {:ok, conn: conn}
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, term_path(conn, :new)
    assert html_response(conn, 200) =~ "New term"
  end

  test "doesn't render form for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    conn = get conn, term_path(conn, :new)
    assert html_response(conn, 403)
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        status: "Planned",
        holidays:
        [
          %{name: "Labor Day 1", date: %{day: 01, month: 05, year: 2010}},
          %{name: "Labor Day 2", date: %{day: 01, month: 02, year: 2010}}
        ]
      }
    conn = post conn, term_path(conn, :create), term: valid_attrs
    assert redirected_to(conn) == term_path(conn, :index)
    assert Repo.get_by(Term, Map.delete(valid_attrs, :holidays))
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

  test "does not create resource and renders errors when holiday is before term start", %{conn: conn} do
    invalid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        status: "Planned",
        holidays:
        [
          %{name: "Labor Day 1", date: %{day: 01, month: 5, year: 2008}},
          %{name: "Labor Day 2", date: %{day: 02, month: 5, year: 2009}}
        ]
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "This holiday is before term"
  end

  test "does not create resource and renders errors when holiday is after term end", %{conn: conn} do
    invalid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        status: "Planned",
        holidays:
        [
          %{name: "Labor Day 1", date: %{day: 02, month: 01, year: 2010}},
          %{name: "Labor Day 2", date: %{day: 02, month: 5, year: 2011}}
        ]
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "This holiday is after term"
  end

  test "doesn't create resource for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    conn = post conn, term_path(conn, :create), term: %{}
    assert html_response(conn, 403)
  end

  test "show existing term", %{conn: conn} do
    {:ok, t} = CoursePlanner.Terms.create(%{name: "Spring", start_date: "2017-04-25", end_date: "2017-05-25", status: "Planned"})
    conn = get conn, term_path(conn, :show, t.id)
    assert html_response(conn, 200) =~ "Show term"
  end

  test "doesn't show existing term for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    {:ok, t} = CoursePlanner.Terms.create(%{name: "Spring", start_date: "2017-04-25", end_date: "2017-05-25", status: "Planned"})
    conn = get conn, term_path(conn, :show, t.id)
    assert html_response(conn, 403)
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

  test "doesn't delete term for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    {:ok, t} = CoursePlanner.Terms.create(%{name: "Spring", start_date: "2017-04-25", end_date: "2017-05-25", status: "Planned"})
    conn = delete conn, term_path(conn, :delete, t.id)
    assert html_response(conn, 403)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = get conn, term_path(conn, :edit, term)
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "doesn't render form for editing for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    term = Repo.insert! %Term{}
    conn = get conn, term_path(conn, :edit, term)
    assert html_response(conn, 403)
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

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    term = create_term()
    conn = put conn, term_path(conn, :update, term), term: %{name: ""}
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "doesn't update resource for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    term = create_term()
    conn = put conn, term_path(conn, :update, term), term: %{name: ""}
    assert html_response(conn, 403)
  end

  test "renders error for updating inexisting resource", %{conn: conn} do
    conn = put conn, term_path(conn, :update, 1), term: %{name: "Fall"}
    assert html_response(conn, 404)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, term_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing terms"
  end

  test "doesn't show index for forbidden user", %{conn: conn} do
    conn = assign(conn, :current_user, @forbidden_user)
    conn = get conn, term_path(conn, :index)
    assert html_response(conn, 403)
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
end
