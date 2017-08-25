defmodule CoursePlanner.TaskViewTest do
  use CoursePlannerWeb.ConnCase, async: true

  alias CoursePlannerWeb.TaskView
  import CoursePlanner.Factory

  test "get_task_volunteer_name_list/1" do
    [volunteer1, volunteer2] = insert_list(2, :volunteer)

    expected_result =
      {:safe, [[[60, "p", [], 62, ["#{volunteer1.name}", [[60, "br", [], 62], 10], "#{volunteer2.name}"], 60, 47, "p", 62], 10]]}
    assert expected_result == TaskView.get_task_volunteer_name_list([volunteer1, volunteer2])
  end

  test "display_volunteer_name_list" do
    [volunteer1, volunteer2] = insert_list(2, :volunteer)
    assert "#{volunteer1.name}\n#{volunteer2.name}" ==  TaskView.display_volunteer_name_list([volunteer1, volunteer2])
  end
end
