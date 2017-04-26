defmodule CoursePlanner.TermController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Terms

  def new(conn, _params) do
    render(conn, "new.html", changeset: Terms.new)
  end

  def create(conn, %{"term" => term_params}) do
    case Terms.create_term(term_params) do
      {:ok, _term} ->
        conn
        |> put_flash(:info, "Term created successfully.")
        |> redirect(to: term_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case Terms.get(id) do
      nil ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      term ->
        render(conn, "show.html", term: term)
    end
  end

  def edit(conn, %{"id" => id}) do
    case Terms.edit(id) do
      nil ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {term, changeset} ->
        render(conn, "edit.html", term: term, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "term" => term_params}) do
    case Terms.update(id, term_params) do
      {:ok, term} ->
        conn
        |> put_flash(:info, "Term updated successfully.")
        |> redirect(to: term_path(conn, :show, term))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, term, changeset} ->
        render(conn, "edit.html", term: term, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Terms.delete(id) do
      {:ok, _term} ->
        conn
        |> put_flash(:info, "Term deleted successfully.")
        |> redirect(to: term_path(conn, :new))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
    end
  end
end
