defmodule CoursePlanner.OfferedCourseViewTest do
  use CoursePlannerWeb.ConnCase, async: true

  alias CoursePlannerWeb.{OfferedCourseView, SharedView}
  import CoursePlanner.Factory

  test "teachers_to_select when there is no teacher" do
    assert [] == OfferedCourseView.teachers_to_select()
  end

  test "teachers_to_select when there are teachers" do
    sorted_teachers =
      insert_list(3, :teacher)
      |> Enum.sort(&(&1.id < &2.id))

    expected_result =
      sorted_teachers
      |> Enum.map(fn(teacher) ->
        full_name = SharedView.display_user_name(teacher)

        %{
          value: teacher.id,
          label: full_name,
          image: SharedView.get_gravatar_url(teacher.email)
        }
      end)

    sorted_teachers_to_select =
      OfferedCourseView.teachers_to_select
      |> Enum.sort(&(&1.value < &2.value))

    assert expected_result == sorted_teachers_to_select
  end
end
