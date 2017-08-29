defmodule CoursePlanner.Notifier.ServerTest do
  use CoursePlannerWeb.ModelCase
  doctest CoursePlanner.Notifications.Server

  import ExUnit.CaptureLog
  import CoursePlanner.Factory
  import Swoosh.TestAssertions

  alias CoursePlanner.{Notifications.Server, Notifications, Accounts.User}

  test "save notification to send later" do
    user = insert(:user)
    notification = Notifications.new()
    |> Notifications.type(:user_modified)
    |> Notifications.resource_path("/")
    |> Notifications.to(user)

    Server.handle_cast({:save_email, notification}, [])
    saved_user = Repo.get(User, user.id) |> Repo.preload(:notifications)
    [saved_notification] = saved_user.notifications
    assert saved_notification.type == "user_modified"
  end

  test "send saved notifications" do
    user = insert(:user)
    insert(:notification, %{user_id: user.id})
    insert(:notification, %{user_id: user.id})
    insert(:notification, %{user_id: user.id})

    saved_user = Repo.get(User, user.id) |> Repo.preload(:notifications)

    Server.handle_cast({:notify_all, saved_user}, [])
    assert_email_sent subject: "Activity Summary"
    sent_user = Repo.get(User, user.id) |> Repo.preload(:notifications)
    assert sent_user.notifications == []
    assert Timex.to_date(sent_user.notified_at) == Timex.today()
  end

  test "send email" do
    user = insert(:user)
    notification = Notifications.new()
    |> Notifications.type(:user_modified)
    |> Notifications.resource_path("/")
    |> Notifications.to(user)

    Server.handle_cast({:send_email, notification}, [])
    assert_email_sent subject: "Your profile is updated"
  end

  test "do not save notification without type" do
    user = insert(:user)
    notification = Notifications.new()
    |> Notifications.resource_path("/")
    |> Notifications.to(user)

    assert capture_log(fn -> Server.handle_cast({:save_email, notification}, []) end) =~ "Email saving failed"

    saved_user = Repo.get(User, user.id) |> Repo.preload(:notifications)
    assert [] == saved_user.notifications
  end

end
