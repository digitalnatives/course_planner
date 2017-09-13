defmodule CoursePlanner.BulkHelper do
  @moduledoc """
    Handle bulk creation specific logics
  """
  alias CoursePlanner.{Repo, Accounts.User}
  alias Coherence.ControllerHelpers
  alias Ecto.{DateTime, Multi}

  @user_required_headers ["name", "family_name", "nickname", "email", "role"]

  def bulk_user_creation(csv_file_stream) do
    csv_parsed_result = csv_parsing(csv_file_stream, @user_required_headers)

    case csv_parsed_result do
      {:ok, parsed_params} -> create_users_with_transaction(parsed_params)
      {:error, message} -> {:error, "bulk_creation", message, ""}
    end
  end

  defp csv_parsing(csv_file_stream, headers) do
    csv_file_stream
    |> CSV.decode(strip_fields: true, headers: headers)
    |> Enum.reduce_while({:ok, []}, fn(parsed_row, {_out_result, out_value}) ->
         case parsed_row do
           {:ok, value} -> {:cont, {:ok, [value | out_value]}}
           {:error, value} -> {:halt, {:error, value}}
         end
       end)
  end

  defp create_users_with_transaction([]),
    do: {:error, "bulk_creation", "Input can not be empty", ""}
  defp create_users_with_transaction(user_records) do
    multi =
      Enum.reduce(user_records, Multi.new, fn(user, out) ->
        token = ControllerHelpers.random_string 48
        params =
          user
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
