defmodule CoursePlanner.NotificationTest do
  use CoursePlannerWeb.ModelCase
  doctest CoursePlanner.Notification

  import CoursePlanner.Factory

  alias CoursePlanner.Notification

  @valid_attrs %{type: "user_modified", resource_path: "/"}
  @invalid_attrs %{type: "invalid_type"}

  test "changeset with valid attributes" do
    user = insert(:user)
    changeset = Notification.changeset(%Notification{}, Map.put(@valid_attrs, :user_id, user.id))
    assert changeset.valid?
  end

  test "changeset with invalid type" do
    changeset = Notification.changeset(%Notification{}, @invalid_attrs)
    refute changeset.valid?
  end

end
