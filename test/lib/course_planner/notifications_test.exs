defmodule CoursePlanner.NotificationsTest do
  use CoursePlanner.ModelCase
  doctest CoursePlanner.Notifications

  import CoursePlanner.Factory

  alias CoursePlanner.Notifications

  test "send notification when it's day after" do
    now = Timex.now()

    user1 = insert(:user, %{notified_at: Timex.shift(now, days: -1), notification_period_days: 1})
    insert(:notification, %{user_id: user1.id})

    user2 = insert(:user, %{notified_at: Timex.shift(now, days: -1), notification_period_days: 2})
    insert(:notification, %{user_id: user2.id})

    user3 = insert(:user, %{notified_at: nil})
    insert(:notification, %{user_id: user3.id})

    [user_to_notiy1, user_to_notiy2] = Notifications.get_notifiable_users(now) |> Enum.sort(&(&1.id < &2.id))
    assert user_to_notiy1.id == user1.id
    assert user_to_notiy2.id == user3.id
  end


end
