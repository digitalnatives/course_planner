defmodule CoursePlannerWeb.BulkController do
  @moduledoc false
  use CoursePlannerWeb, :controller
  alias CoursePlanner.BulkHelper
  alias Coherence.ControllerHelpers
  alias CoursePlannerWeb.Router.Helpers

  import Canary.Plugs
  plug :authorize_controller

  def new(conn, %{"target" => target, "title" => title}) do
    render(conn, "new.html", target: target, title: title)
  end

  def create(conn, %{"input" => %{"target" => target,
                                  "title" => title,
                                  "csv_file" => %{"path" => file_path}}}) do
    file_path
    |> File.stream!()
    |> handle_csv_file_data(conn, target, title)
  end
  def create(conn, %{"input" => %{"target" => target, "title" => title}}) do
    conn
    |> put_flash(:error, "You have to select a file.")
    |> render("new.html", target: target, title: title)
  end

  defp handle_csv_file_data(file_stream, conn, target, title) do
    case bulk_target_handler(file_stream, target) do
      {:ok, created_entities} ->
        post_creation(conn, created_entities, target)

        conn
        |> put_flash(:info, "All users are created and notified by.")
        |> redirect(to: user_path(conn, :index))
      {:error, "parsing_csv", failed_value, _changes_so_far} ->

        conn
        |> put_flash(:error, failed_value)
        |> render("new.html", target: target, title: title)
      {:error, _failed_operation, %{errors: errors}, _changes_so_far} ->
        {error_field, {error_message, _etc}} = List.first(errors)

        conn
        |> put_flash(:error, "#{error_field} #{error_message}")
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
      _      -> {:error, "", "", ""}
    end
  end

  defp post_creation(conn, created_entities, target) do
    case target do
      "user" ->
        created_entities
        |> Enum.reduce(%{}, fn({_operation_id, user}, _out) ->
            url = Helpers.password_url(conn, :edit, user.reset_password_token)
            ControllerHelpers.send_user_email(:welcome, user, url)
          end)
        {:ok, created_entities}
      _  -> {:ok, :ok}
    end
  end
end
