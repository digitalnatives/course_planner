defmodule CoursePlanner.BulkHelper do
  @moduledoc """
    Handle bulk creation specific logics
  """
  alias CoursePlanner.{Repo, Accounts.User}
  alias Coherence.ControllerHelpers
  alias Ecto.{DateTime, Multi}

  def bulk_user_creation(csv_file_stream) do
    csv_parsed_result = csv_parsing(csv_file_stream)

    case validate_column_count(csv_parsed_result, 5) do
      {:ok, parsed_params} ->
        create_users_with_transaction(parsed_params)
      {:validate_error, row_index} ->
        {:error, "parsing_csv",
          "Input data in row ##{row_index + 1} is not matching the column number.", ""}
      {:error, :empty} ->
        {:error, "parsing_csv", "Input can not be empty.", ""}
      {:error, message} ->
        {:error, "parsing_csv", message, ""}
    end
  end

  defp csv_parsing(csv_file_stream) do
    csv_file_stream
    |> CSV.decode
    |> Enum.reduce_while({:ok, []}, fn(parsed_row, {_out_result, out_value}) ->
         case parsed_row do
           {:ok, value} -> {:cont, {:ok, [value | out_value]}}
           {:error, value} -> {:halt, {:error, value}}
         end
       end)
  end

  def validate_column_count({:error, parsed_params}, _column_count), do: {:error, parsed_params}
  def validate_column_count({:ok, []}, _column_count), do: {:error, :empty}
  def validate_column_count({:ok, trimmed_splitted_csv}, column_count) do
    trimmed_splitted_csv
    |> Enum.with_index
    |> Enum.reduce_while({:ok, []}, fn({row, index}, {_out_result, out_value}) ->
          case validate_row(row, column_count) do
            false -> {:halt, {:validate_error, index}}
            true  -> {:cont, {:ok, [row | out_value]}}
          end
       end)
  end

  def validate_row(row_data, required_column_count) do
    row_data
    |> length()
    |> rem(required_column_count)
    |> Kernel.==(0)
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
