defmodule CoursePlanner.HolidayTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Terms.Holiday

  test "changeset with valid date" do
    valid_attrs =
      %{
        name: "Labor Day", date: %{day: 02, month: 5, year: 2015}
      }
    changeset = Holiday.changeset(%Holiday{}, ~D[2015-05-01], ~D[2015-05-03], valid_attrs)
    assert changeset.valid?
  end

  test "changeset with date before term start date" do
    valid_attrs =
      %{
        name: "Labor Day", date: %{day: 02, month: 5, year: 2014}
      }
    changeset = Holiday.changeset(%Holiday{}, ~D[2015-05-01], ~D[2015-05-03], valid_attrs)
    refute changeset.valid?
  end

  test "changeset with date after term end date" do
    valid_attrs =
      %{
        name: "Labor Day", date: %{day: 02, month: 5, year: 2016}
      }
    changeset = Holiday.changeset(%Holiday{}, ~D[2015-05-01], ~D[2015-05-03], valid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid holiday" do
    valid_attrs =
      %{
        name: "Labor Day", date: nil
      }
    changeset = Holiday.changeset(%Holiday{}, ~D[2015-05-01], ~D[2015-05-03], valid_attrs)
    refute changeset.valid?
  end
end
