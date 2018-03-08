defmodule CoursePlanner.SettingsTest do
  use CoursePlannerWeb.ModelCase

  alias CoursePlanner.Settings
  import CoursePlanner.Factory

  setup do
    insert(:system_variable, %{key: "TIMEZONE", value: "Europe/Budapest", type: "timezone"})
    :ok
  end

  describe "test the get_value" do
    test "when key does not exist" do
      assert Settings.get_value("TEST_KEY") == nil
    end

    test "when key does not exist and default value is set" do
      assert Settings.get_value("TEST_KEY", "NOT_FOUND") == "NOT_FOUND"
    end

    test "when variable type is string" do
      value = "random value"
      insert(:system_variable, %{key: "TEST_KEY", value: value, type: "string"})
      assert value == Settings.get_value("TEST_KEY")
    end

    test "when variable type is integer" do
      value = 10
      insert(:system_variable, %{key: "TEST_KEY", value: "#{value}", type: "integer"})
      assert value == Settings.get_value("TEST_KEY")
    end

    test "when variable type is boolean" do
      value = true
      insert(:system_variable, %{key: "TEST_KEY", value: "#{value}", type: "boolean"})
      assert value == Settings.get_value("TEST_KEY")
    end

    test "when variable type is list" do
      value = "value1, value2"
      insert(:system_variable, %{key: "TEST_KEY", value: value, type: "list"})
      assert ["value1", "value2"] == Settings.get_value("TEST_KEY")
    end

    test "when variable type is url and is empty to return nil" do
      insert(:system_variable, %{key: "TEST_KEY", value: "", type: "url"})
      assert nil == Settings.get_value("TEST_KEY")
    end
  end

  describe "timezone functions" do
    test "retrieve current time using Timex.now()" do
      now = Timex.now()
      shifted = Settings.utc_to_system_timezone(now)
      assert shifted.time_zone == "Europe/Budapest"
    end

    test "retrieve current time using naive datetime" do
      now = ~N[2017-01-01 15:00:00]
      shifted = Settings.utc_to_system_timezone(now)
      assert shifted.time_zone == "Europe/Budapest"
    end

    test "retrieve current time using ecto datetime" do
      now = Ecto.DateTime.utc()
      shifted = Settings.utc_to_system_timezone(now)
      assert shifted.time_zone == "Europe/Budapest"
    end
  end
end
