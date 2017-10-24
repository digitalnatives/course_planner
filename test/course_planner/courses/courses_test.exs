defmodule CoursePlanner.CoursesTest do
  use CoursePlannerWeb.ModelCase

  import CoursePlanner.Factory

  alias CoursePlanner.{Courses, Repo, Notifications.Notification}

  test "notify user" do
    user = insert(:teacher)
    type = :course_created
    path = "/sample_path"

    Courses.notify_user(user, type, path)
    assert Repo.get_by(Notification, user_id: user.id, type: to_string(type), resource_path: path)
  end
end
