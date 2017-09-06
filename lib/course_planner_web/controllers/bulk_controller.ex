defmodule CoursePlannerWeb.BulkController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.BulkHelper

  import Canary.Plugs
  plug :authorize_controller

  def new(conn, %{"target" => target, "title" => title}) do
    render(conn, "new.html", target: target, title: title)
  end

  def create(conn, %{"input" => %{"csv_data" => csv_data, "target" => target, "title" => title}}) do
    case bulk_target_handler(csv_data, target) do
      {:ok, _entities} ->
        conn
        |> put_flash(:info, "All users are created and notified by.")
        |> redirect(to: user_path(conn, :index))
      {:error, "bulk_user_creation", failed_value, _changes_so_far} ->
        conn
        |> put_flash(:error, failed_value)
        |> render("new.html", target: target, title: title)
      {:error, _failed_operation, %{errors: errors}, _changes_so_far} ->
        {error_field, {error_message, _etc}} = List.first(errors)

        conn
        |> put_flash(:error, "#{to_string(error_field)} #{error_message}")
        |> render("new.html", target: target, title: title)
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", target: target, title: title)
    end
  end

  defp bulk_target_handler(csv_data, target) do
    case target do
      "user" -> BulkHelper.bulk_user_creation(csv_data)
      _      -> {:error, "", :illegal_operation, ""}
    end
  end
end
