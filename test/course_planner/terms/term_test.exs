defmodule CoursePlanner.TermTest do
  use CoursePlannerWeb.ModelCase

  alias CoursePlanner.{Terms.Term, Terms}

  test "changeset with valid attributes" do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 17, month: 4, year: 2010},
        end_date: %{day: 17, month: 5, year: 2010},
        minimum_teaching_days: 5
      }
    changeset = Term.changeset(%Term{}, valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    invalid_attrs = %{start_date: "123", end_date: nil}
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end

  test "start_date same as end_date" do
    invalid_attrs =
      %{
        name: "Spring",
        minimum_teaching_days: 1,
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
        end_date: %{day: 17, month: 3, year: 2010},
        minimum_teaching_days: 5,
      }
    changeset = Term.changeset(%Term{}, invalid_attrs)
    refute changeset.valid?
  end

  test "term has minimum teaching days" do
    {:ok, term} = Terms.create(%{
      "name" => "Spring",
      "start_date" => %{day: 17, month: 3, year: 2017},
      "end_date" => %{day: 22, month: 3, year: 2017},
      "minimum_teaching_days" => 3,
      "holidays" => %{
        "0" => %{name: "Labor Day 1", date: %{day: 18, month: 3, year: 2017}},
        "1" => %{name: "Labor Day 2", date: %{day: 19, month: 3, year: 2017}}
      }
    })
    assert length(term.holidays) == 2
  end

  test "term doesn't have minimum teaching days" do
    {:error, changeset} = Terms.create(%{
      "name" => "Spring",
      "start_date" => %{day: 17, month: 3, year: 2017},
      "end_date" => %{day: 20, month: 3, year: 2017},
      "minimum_teaching_days" => 3,
      "holidays" => %{
        "0" => %{name: "Labor Day 1", date: %{day: 18, month: 3, year: 2017}},
        "1" => %{name: "Labor Day 2", date: %{day: 19, month: 3, year: 2017}}
      }
    })
    refute changeset.valid?
    assert changeset.errors[:minimum_teaching_days] == {"There's not enough minimum teaching days.", []}
  end

  test "term doesn't have minimum teaching days without holidays" do
    {:error, changeset} = Terms.create(%{
      "name" => "Spring",
      "start_date" => %{day: 17, month: 3, year: 2017},
      "end_date" => %{day: 20, month: 3, year: 2017},
      "minimum_teaching_days" => 5
    })
    refute changeset.valid?
    assert changeset.errors[:minimum_teaching_days] == {"There's not enough minimum teaching days.", []}
  end
end
