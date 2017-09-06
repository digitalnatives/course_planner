defmodule CoursePlanner.BulkHelper do
  @moduledoc """
    Handle Students specific logics
  """
  alias CoursePlanner.{CsvParser, Repo, User}
  alias Coherence.ControllerHelpers
  alias Ecto.{DateTime, Multi}

  def bulk_user_creation(csv_data) do
    csv_parsed_result = CsvParser.parse(csv_data, 5)
    operation_name = "bulk_user_creation"
    case csv_parsed_result do
      {:ok, parsed_params} ->
        create_users_with_transaction(parsed_params)
      {:error, message} ->
        {:error, operation_name, message, ""}
    end
  end

  defp create_users_with_transaction(student_records) do
    multi =
      Enum.reduce(student_records, Multi.new, fn(student, out) ->
        [name, family_name, nickname, email, role] = student
        token = ControllerHelpers.random_string 48
        params = %{}
          |> Map.put_new("name", name)
          |> Map.put_new("family_name", family_name)
          |> Map.put_new("nickname", nickname)
          |> Map.put_new("email", email)
          |> Map.put_new("role", role)
          |> Map.put_new("reset_password_token", token)
          |> Map.put_new("reset_password_sent_at", DateTime.utc())
          |> Map.put_new("password", "fakepassword")
          |> Map.put_new("password_confirmation", "fakepassword")

        changeset = User.changeset(%User{}, params, :bulk)

        Multi.insert(out, token, changeset)
      end)
    Repo.transaction(multi)
  end

  def notify__created_users(_created_record) do

  end
end
