defmodule CoursePlanner.SettingTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Setting

  @valid_attrs %{notification_frequency: "10", program_address: "some content", program_description: "some content", program_email_address: "some content", program_name: "some content", program_phone_number: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Setting.changeset(%Setting{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Setting.changeset(%Setting{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "notification_frequency's low boundary" do
    changeset = Setting.changeset(%Setting{}, %{@valid_attrs | notification_frequency: 1})
    assert changeset.valid?

    changeset = Setting.changeset(%Setting{}, %{@valid_attrs | notification_frequency: 0})
    refute changeset.valid?
  end

  test "notification_frequency's high boundary" do
    changeset = Setting.changeset(%Setting{}, %{@valid_attrs | notification_frequency: 31})
    assert changeset.valid?

    changeset = Setting.changeset(%Setting{}, %{@valid_attrs | notification_frequency: 32})
    refute changeset.valid?
  end
end
