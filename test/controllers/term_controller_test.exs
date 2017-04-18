defmodule CoursePlanner.TermControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Term
  @valid_attrs %{deleted_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, finished_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, finishing_day: %{day: 17, month: 4, year: 2010}, frozen_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, holidays: [], name: "some content", starting_day: %{day: 17, month: 4, year: 2010}, status: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, term_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing terms"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, term_path(conn, :new)
    assert html_response(conn, 200) =~ "New term"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, term_path(conn, :create), term: @valid_attrs
    assert redirected_to(conn) == term_path(conn, :index)
    assert Repo.get_by(Term, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, term_path(conn, :create), term: @invalid_attrs
    assert html_response(conn, 200) =~ "New term"
  end

  test "shows chosen resource", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = get conn, term_path(conn, :show, term)
    assert html_response(conn, 200) =~ "Show term"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, term_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = get conn, term_path(conn, :edit, term)
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = put conn, term_path(conn, :update, term), term: @valid_attrs
    assert redirected_to(conn) == term_path(conn, :show, term)
    assert Repo.get_by(Term, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = put conn, term_path(conn, :update, term), term: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit term"
  end

  test "deletes chosen resource", %{conn: conn} do
    term = Repo.insert! %Term{}
    conn = delete conn, term_path(conn, :delete, term)
    assert redirected_to(conn) == term_path(conn, :index)
    refute Repo.get(Term, term.id)
  end
end
