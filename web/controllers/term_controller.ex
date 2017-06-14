defmodule CoursePlanner.TermController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Terms
  alias Ecto.Changeset

  import Canary.Plugs
  plug :authorize_resource, model: Terms.Term

  def index(conn, _params) do
    render(conn, "index.html", terms: Terms.all)
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Terms.new)
  end

  def create(conn, %{"term" => term_params}) do
    case Terms.create(term_params) do
      {:ok, _term} ->
        conn
        |> put_flash(:info, "Term created successfully.")
        |> redirect(to: term_path(conn, :index))
      {:error, changeset} ->
        changeset = Changeset.put_change(changeset, :courses, [])
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
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:ok, term, changeset} ->
        render(conn, "edit.html", term: term, changeset: changeset)
    end
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"id" => id, "term" => term_params}) do
    case Terms.update(id, term_params) do
      {:ok, term} ->
        Terms.notify_term_users(term, current_user, :term_updated, term_url(conn, :show, term))
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

  def delete(%{assigns: %{current_user: current_user}} = conn, %{"id" => id}) do
    case Terms.delete(id) do
      {:ok, term} ->
        Terms.notify_term_users(term, current_user, :term_deleted)
        conn
        |> put_flash(:info, "Term deleted successfully.")
        |> redirect(to: term_path(conn, :index))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlanner.ErrorView, "404.html")
      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> render(CoursePlanner.ErrorView, "500.html")
    end
  end
end
