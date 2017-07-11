defmodule CoursePlanner.SettingsTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Settings
  import CoursePlanner.Factory

  describe "test the get_value" do
    test "when key does not exist" do
      assert Settings.get_value("TEST_KEY") == nil
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

    test "when variable type is csv" do
      value = "value1, value2"
      insert(:system_variable, %{key: "TEST_KEY", value: value, type: "csv"})
      assert ["value1", "value2"] == Settings.get_value("TEST_KEY")
    end
  end
end
