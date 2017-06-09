defmodule CoursePlanner.TermTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Terms.Term

  test "changeset with valid attributes" do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 5, year: 2010}
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
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 5, year: 2017},
        holidays:
          [
            %{name: "Labor Day", date: %{day: 01, month: 5, year: 2015}}
          ]
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with holidays before term start date" do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 5, year: 2010},
        status: "Planned",
        holidays:
          [
            %{name: "Labor Day 1", date: %{day: 01, month: 5, year: 2009}},
            %{name: "Labor Day 2", date: %{day: 02, month: 5, year: 2009}}
          ]
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    refute changeset.valid?
  end

  test "changeset with holidays after term end date" do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 5, year: 2010},
        status: "Planned",
        holidays:
          [
            %{name: "Labor Day 1", date: %{day: 01, month: 5, year: 2011}},
            %{name: "Labor Day 2", date: %{day: 02, month: 5, year: 2011}}
          ]
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    refute changeset.valid?
  end

  test "changeset with holidays before and after term" do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 5, year: 2010},
        status: "Planned",
        holidays:
          [
            %{name: "Labor Day 1", date: %{day: 01, month: 5, year: 2008}},
            %{name: "Labor Day 2", date: %{day: 02, month: 5, year: 2011}}
          ]
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid holidays" do
    invalid_attrs =
      %{
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 4, year: 2010},
        holidays:
          [
            %{name: "Labor Day", date: nil}
          ]
      }
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end

  test "start_date same as end_date" do
    invalid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 4, year: 2010}
      }
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end

  test "start_date before end_date" do
    invalid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 3, year: 2010}
      }
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end
end
