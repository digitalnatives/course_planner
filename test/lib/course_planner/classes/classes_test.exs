defmodule CoursePlanner.ClassesTest do
  use CoursePlannerWeb.ModelCase

  import CoursePlanner.Factory
  alias CoursePlanner.Classes


  test "sort by starting time when input is an empty list" do
    assert [] = Classes.sort_by_starting_time([])
  end

  test "sort by starting time for multiple classes" do
    class1 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: -2))
    class2 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: +1))
    class3 = insert(:class, date: Timex.now(), starting_at: Timex.now())
    class4 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), minutes: -2))
    class5 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), minutes: +2))

    classes = [class1, class2, class3, class4, class5]
    expected_result = [class1, class4, class3, class5, class2]

    assert expected_result == Classes.sort_by_starting_time(classes)
  end

  test "split past and next classes when input is an empty list" do
    assert {[],[]} = Classes.split_past_and_next([])
  end

  test "split past and next classes for multiple classes" do
    class1 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: -2))
    class2 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: +1))
    class3 = insert(:class, date: Timex.now(), starting_at: Timex.now())
    class4 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), minutes: -2))
    class5 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), minutes: +2))

    classes = [class1, class2, class3, class4, class5]
    expected_past_classes =
      [class1.id, class4.id]
      |> Enum.sort()

    expected_next_classes =
      [class3.id, class5.id, class2.id]
      |> Enum.sort()

    {past_classes, next_classes} =
      Classes.split_past_and_next(classes)

    sorted_past_classes_result =
      past_classes
      |> Enum.map(&(&1.id))
      |> Enum.sort()

    sorted_next_classes_result =
      next_classes
      |> Enum.map(&(&1.id))
      |> Enum.sort()

    assert expected_past_classes == sorted_past_classes_result
    assert expected_next_classes == sorted_next_classes_result
  end

  test "split past and next classes for multiple classes and no next class" do
    class1 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: -2))
    class2 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: -1))
    class3 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: -3))

    classes = [class1, class2, class3]
    expected_past_classes =
      [class1.id, class2.id, class3.id]
      |> Enum.sort()

    expected_next_classes = []

    {past_classes, next_classes} =
      Classes.split_past_and_next(classes)

    sorted_past_classes_result =
      past_classes
      |> Enum.map(&(&1.id))
      |> Enum.sort()

    sorted_next_classes_result =
      next_classes
      |> Enum.map(&(&1.id))
      |> Enum.sort()

    assert expected_past_classes == sorted_past_classes_result
    assert expected_next_classes == sorted_next_classes_result
  end

  test "split past and next classes for multiple classes and no past class" do
    class1 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: +2))
    class2 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: +1))
    class3 = insert(:class, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: +3))

    classes = [class1, class2, class3]
    expected_past_classes = []

    expected_next_classes =
      [class1.id, class2.id, class3.id]
      |> Enum.sort()

    {past_classes, next_classes} =
      Classes.split_past_and_next(classes)

    sorted_past_classes_result =
      past_classes
      |> Enum.map(&(&1.id))
      |> Enum.sort()

    sorted_next_classes_result =
      next_classes
      |> Enum.map(&(&1.id))
      |> Enum.sort()

    assert expected_past_classes == sorted_past_classes_result
    assert expected_next_classes == sorted_next_classes_result
  end
end
