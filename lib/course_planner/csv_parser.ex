defmodule CoursePlanner.CsvParser do
  @moduledoc false

  @csv_seperator ","

  def parse(csv_data, column_count) do
    splited_csv = csv_splitter(csv_data)
    if validate_column_count(splited_csv, column_count) do
      {:ok, csv_data_formatter(splited_csv, column_count)}
    else
      {:error, "input data is not matching the column number"}
    end
  end

  defp csv_splitter(csv_data) do
    String.split(csv_data, @csv_seperator)
  end

  defp validate_column_count(splited_csv, column_count) do
    splited_csv
    |> length()
    |> rem(column_count)
    |> Kernel.==(0)
  end

  defp csv_data_formatter(splited_csv, column_count),
    do: csv_data_formatter(splited_csv, column_count, [])
  defp csv_data_formatter([], _column_count, out), do: out
  defp csv_data_formatter(splited_csv, column_count, out) do
    {result, remaining} = Enum.split(splited_csv, column_count)
    csv_data_formatter(remaining, column_count, out ++ [result])
  end
end
