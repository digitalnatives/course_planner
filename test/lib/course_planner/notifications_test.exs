defmodule CoursePlanner.NotificationsTest do
  use CoursePlanner.ModelCase
  doctest CoursePlanner.Notifications

  import CoursePlanner.Factory

  alias CoursePlanner.Notifications

  test "send notification when it's day after" do
    today = Timex.today()

    user1 = insert(:user, %{notified_at: Timex.shift(today, days: -1), notification_period_days: 1})
    insert(:notification, %{user_id: user1.id})

    user2 = insert(:user, %{notified_at: Timex.shift(today, days: -1), notification_period_days: 2})
    insert(:notification, %{user_id: user2.id})

    [user_to_notiy] = Notifications.get_notifiable_users(today)
    assert user_to_notiy.id == user1.id
  end


end
