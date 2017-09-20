defmodule CoursePlannerWeb.TermController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.Terms
  alias Ecto.Changeset

  import Canary.Plugs
  plug :authorize_controller
  action_fallback CoursePlannerWeb.FallbackController

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
      {:ok, term} ->
        term_with_offered_courses =
          Repo.preload(term, [offered_courses: [:course, :term]])
        render(conn, "show.html", term: term_with_offered_courses)
      error -> error
    end
  end

  def edit(conn, %{"id" => id}) do
    case Terms.edit(id) do
      {:ok, term, changeset} ->
        render(conn, "edit.html", term: term, changeset: changeset)
      error -> error
    end
  end

  def update(
    %{assigns: %{current_user: current_user}} = conn,
    %{"id" => id, "term" => term_params}) do

    case Terms.update(id, term_params) do
      {:ok, term} ->
        Terms.notify_term_users(term, current_user, :term_updated, term_url(conn, :show, term))
        conn
        |> put_flash(:info, "Term updated successfully.")
        |> redirect(to: term_path(conn, :show, term))
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
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
      {:error, :not_found} -> {:error, :not_found}
      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> render(CoursePlannerWeb.ErrorView, "500.html")
    end
  end
end
