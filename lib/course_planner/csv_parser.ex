defmodule CoursePlanner.CsvParser do
  @moduledoc false

  @csv_seperator ","

  def parse(csv_data, column_count, trim_elements \\ true) do
    splited_csv = csv_splitter(csv_data)
    trimmed_splitted_csv =
      if trim_elements do
        trim_splitted_csv(splited_csv)
      else
        splited_csv
      end

    if validate_column_count(trimmed_splitted_csv, column_count) do
      {:ok, Enum.chunk_every(trimmed_splitted_csv, column_count)}
    else
      {:error, "input data is not matching the column number"}
    end
  end

  defp trim_splitted_csv(splited_csv) do
    Enum.map(splited_csv, &(String.trim(&1)))
  end

  defp csv_splitter(csv_data) do
    String.split(csv_data, @csv_seperator)
  end

  defp validate_column_count(trimmed_splitted_csv, column_count) do
    trimmed_splitted_csv
    |> length()
    |> rem(column_count)
    |> Kernel.==(0)
  end
end
