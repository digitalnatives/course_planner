defmodule CoursePlanner.TermController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Term

  def index(conn, _params) do
    terms = Repo.all(Term)
    render(conn, "index.html", terms: terms)
  end

  def new(conn, _params) do
    changeset = Term.changeset(%Term{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"term" => term_params}) do
    changeset = Term.changeset(%Term{}, term_params)

    case Repo.insert(changeset) do
      {:ok, _term} ->
        conn
        |> put_flash(:info, "Term created successfully.")
        |> redirect(to: term_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    term = Repo.get!(Term, id)
    render(conn, "show.html", term: term)
  end

  def edit(conn, %{"id" => id}) do
    term = Repo.get!(Term, id)
    changeset = Term.changeset(term)
    render(conn, "edit.html", term: term, changeset: changeset)
  end

  def update(conn, %{"id" => id, "term" => term_params}) do
    term = Repo.get!(Term, id)
    changeset = Term.changeset(term, term_params)

    case Repo.update(changeset) do
      {:ok, term} ->
        conn
        |> put_flash(:info, "Term updated successfully.")
        |> redirect(to: term_path(conn, :show, term))
      {:error, changeset} ->
        render(conn, "edit.html", term: term, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    term = Repo.get!(Term, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(term)

    conn
    |> put_flash(:info, "Term deleted successfully.")
    |> redirect(to: term_path(conn, :index))
  end
end
