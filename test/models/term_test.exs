defmodule CoursePlanner.TermTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Terms.Term

  test "changeset with valid attributes" do
    valid_attrs =
      %{
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 4, year: 2010},
        status: "Planned"
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    invalid_attrs = %{start_date: "123", end_date: nil}
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with valid holidays" do
    valid_attrs =
      %{
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 4, year: 2010},
        status: "Planned",
        holidays:
          [
            %{name: "Labor Day", date: %{day: 01, month: 5, year: 2017}}
          ]
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid holidays" do
    invalid_attrs =
      %{
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 4, year: 2010},
        status: "Planned",
        holidays:
          [
            %{name: "Labor Day", date: nil}
          ]
      }
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end
end
