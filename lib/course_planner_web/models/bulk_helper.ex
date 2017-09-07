defmodule CoursePlanner.BulkHelper do
  @moduledoc """
    Handle Students specific logics
  """
  alias CoursePlanner.{CsvParser, Repo, User}
  alias Coherence.ControllerHelpers
  alias Ecto.{DateTime, Multi}

  def bulk_user_creation(csv_data) do
    csv_parsed_result = CsvParser.parse(csv_data, 5)
    case csv_parsed_result do
      {:ok, parsed_params} ->
        create_users_with_transaction(parsed_params)
      {:error, message} ->
        {:error, "parsing_csv", message, ""}
    end
  end

  defp create_users_with_transaction(user_records) do
    multi =
      Enum.reduce(user_records, Multi.new, fn(user, out) ->
        [name, family_name, nickname, email, role] = user
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
end
