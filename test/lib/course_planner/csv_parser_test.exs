defmodule CoursePlanner.CsvParserTest do
  use CoursePlannerWeb.ModelCase

  alias CoursePlanner.CsvParser

  import ExUnit.Assertions

  test "parsing with required column zero" do
    assert_raise ArithmeticError, fn ->
      CsvParser.parse("a,b,c", 0)
    end
  end

  test "parsing a string with empty elements" do
    assert CsvParser.parse(",,", 3) == {:ok, [["","",""]]}
  end

  test "when data and required columns do not match" do
    assert CsvParser.parse("", 4) == {:error, "Input data is not matching the column number."}
    assert CsvParser.parse("a,b,c", 4) == {:error, "Input data is not matching the column number."}
    assert CsvParser.parse("a,b,c,d,e", 4) == {:error, "Input data is not matching the column number."}
    assert CsvParser.parse("a,b,c,d,e,f,g,h,i", 4) == {:error, "Input data is not matching the column number."}
  end

  test "when input has one set of data" do
    assert CsvParser.parse("a,b,c,d", 4) == {:ok, [["a","b","c", "d"]]}
  end

  test "when input has more than one set of data" do
    assert CsvParser.parse("a,b,c,d,e,f,g,h", 4) == {:ok, [["a","b","c", "d"], ["e","f","g","h"]]}
  end

  test "parsing csv with element space trimming" do
    assert CsvParser.parse(" a, b , c, d d ", 4) == {:ok, [["a","b","c", "d d"]]}
  end

  test "parsing csv without element space trimming" do
    assert CsvParser.parse(" a, b , c, d d ", 4, false) == {:ok, [[" a"," b "," c", " d d "]]}
  end

  test "parsing csv returns empty elements as empty strings" do
    assert CsvParser.parse("a, ,,d", 4, false) == {:ok, [["a"," ","","d"]]}
    assert CsvParser.parse("a, ,,d", 4, true) == {:ok, [["a","","","d"]]}
  end
end
