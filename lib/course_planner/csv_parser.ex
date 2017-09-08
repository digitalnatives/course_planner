defmodule CoursePlanner.CsvParser do
  @moduledoc false

  @csv_row_seperator "\n"
  @csv_element_seperator ","

  def parse(csv_data, column_count, trim_elements \\ true) do
    trimmed_and_splitted_csv = csv_splitter(csv_data, trim_elements)

#    if validate_column_count(trimmed_and_splitted_csv, column_count) do
#      {:ok, trimmed_and_splitted_csv}
#    else
#      {:error, "Input data is not matching the column number."}
#    end

    case validate_column_count(trimmed_and_splitted_csv, column_count) do
      {:ok, :ok} -> {:ok, trimmed_and_splitted_csv}
      {:error, :empty} -> {:error, "Input can not be empty."}
      {:error, row_index} ->
        {:error, "Input data in row ##{row_index + 1} is not matching the column number."}
    end
  end

  defp trim_splitted_csv(splited_csv) do
    Enum.map(splited_csv, &(String.trim(&1)))
  end

  defp csv_splitter(csv_data, trim_elements) do
    csv_data
    |> String.split(@csv_row_seperator, trim: true)
    |> Enum.map(fn(row) ->
        splited_csv = String.split(row, @csv_element_seperator)

        if trim_elements do
          trim_splitted_csv(splited_csv)
        else
          splited_csv
        end
      end)
  end

  defp validate_column_count([], _column_count), do: {:error, :empty}
  defp validate_column_count(trimmed_splitted_csv, column_count) do
    trimmed_splitted_csv
    |> Enum.with_index
    |> Enum.reduce_while(true, fn({row, index}, _out) ->
          case validate_row(row, column_count) do
            false -> {:halt, {:error, index}}
            true  -> {:cont, {:ok, :ok}}
          end
       end)
  end

  def validate_row(row_data, required_column_count) do
    row_data
    |> length()
    |> rem(required_column_count)
    |> Kernel.==(0)
  end
end
