defmodule CoursePlannerWeb.EventController do
  @moduledoc false
  use CoursePlannerWeb, :controller

  alias CoursePlanner.Events
  alias CoursePlanner.Events.Event

  import Canary.Plugs
  plug :authorize_controller

  def index(conn, _params) do
    events = Events.all()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    case Events.create(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: event_path(conn, :show, event))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case Events.get(id) do
      {:ok, event} -> render(conn, "show.html", event: event)
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(CoursePlannerWeb.ErrorView, "404.html")
    end

  end

  def edit(conn, %{"id" => id}) do
    {:ok, event} = Events.get(id)
    changeset = Events.change(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    {:ok, event} = Events.get(id)

    case Events.update(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: event_path(conn, :show, event))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, event} <- Events.get(id),
         {:ok, _event} <- Events.delete(event)
      do
        conn
        |> put_flash(:info, "Event deleted successfully.")
        |> redirect(to: event_path(conn, :index))
      else
        {:ok, :not_found} ->
          conn
          |> put_status(404)
          |> render(CoursePlannerWeb.ErrorView, "404.html")
    end
  end
end
