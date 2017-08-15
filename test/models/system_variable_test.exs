defmodule CoursePlanner.SystemVariableTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.SystemVariable

  @string_valid_attrs %{key: "sample key", value: "sample value", type: "string", visible: true, editable: true, required: true}
  @text_valid_attrs %{key: "sample key", value: "sample value", type: "text", visible: true, editable: true, required: true}
  @url_valid_attrs %{key: "sample key", value: "http://www.sample.com", type: "url", visible: true, editable: true, required: true}
  @integer_valid_attrs %{key: "sample key", value: "1", type: "integer", visible: true, editable: true, required: true}
  @boolean_valid_attrs %{key: "sample key", value: "true", type: "boolean", visible: true, editable: true, required: true}
  @list_valid_attrs %{key: "sample key", value: "value1,value2", type: "list", visible: true, editable: true, required: true}
  @utc_datetime_valid_attrs %{key: "sample key", value: "2017-08-15T09:07:59.935703Z", type: "utc_datetime", visible: true, editable: true, required: true}
  @invalid_attrs %{}

  test "changeset with invalid attributes" do
    changeset = SystemVariable.changeset(%SystemVariable{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset fails for uneditable system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | editable: false}, :update)
    refute changeset.valid?
  end

  describe "changeset for string input type validation" do
    test "valid changeset when input is not empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: "random"})
      assert changeset.valid?
    end

    test "valid changeset when input can be interpreted as integer" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: "112"})
      assert changeset.valid?
    end

    test "valid changeset when input can be interpreted as boolean" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: "true"})
      assert changeset.valid?
    end

    test "changeset fails when input is empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: ""})
      refute changeset.valid?
    end

    test "changeset passes when input is empty but field is not required" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: "", required: false})
      assert changeset.valid?
    end

    test "changeset fails when input is more than 255 charactes" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: String.duplicate("a", 500)})
      refute changeset.valid?
    end
  end

  describe "changeset for text input type validation" do
    test "valid changeset when input is not empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@text_valid_attrs | value: "random"})
      assert changeset.valid?
    end

    test "valid changeset when input can be interpreted as integer" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@text_valid_attrs | value: "112"})
      assert changeset.valid?
    end

    test "valid changeset when input can be interpreted as boolean" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@text_valid_attrs | value: "true"})
      assert changeset.valid?
    end

    test "changeset fails when input is empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@text_valid_attrs | value: ""})
      refute changeset.valid?
    end

    test "valid changeset when input is more than 255 charactes" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@text_valid_attrs | value: String.duplicate("a", 500)})
      assert changeset.valid?
    end
  end

  describe "changeset for url input type validation" do
    test "url is valid" do
      changeset = SystemVariable.changeset(%SystemVariable{}, @url_valid_attrs)
      assert changeset.valid?
    end

    test "changeset fails when url has no scheme" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@url_valid_attrs | value: "www.sample.com"})
      refute changeset.valid?
    end

    test "changeset fails when url has no host" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@url_valid_attrs | value: "http://"})
      refute changeset.valid?
    end

    test "changeset fails when url is empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@url_valid_attrs | value: ""})
      refute changeset.valid?
    end

    test "changeset fails when url is nil" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@url_valid_attrs | value: nil})
      refute changeset.valid?
    end
  end

  describe "boundary for integer typed system_variable" do
    test "changeset fails when input is less than 0" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "-1"})
      refute changeset.valid?
    end

    test "changeset fails when input is more than 1000000" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1000001"})
      refute changeset.valid?
    end
  end

  describe "changeset for integer input type validation" do
    test "changeset for valid integer system variable" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "0"})
      assert changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1000"})
      assert changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1000000"})
      assert changeset.valid?
    end

    test "changeset fails when input has floating point" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1.1"})
      refute changeset.valid?
    end

    test "changeset fails when integer is a subset of input" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1ab"})
      refute changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "ab1"})
      refute changeset.valid?
    end

    test "changeset fails when number is seperated by a character" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1 1"})
      refute changeset.valid?
    end

    test "changeset fails when input is described in elixir terms" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1_000_000"})
      refute changeset.valid?
    end
  end

  describe "changeset for boolean type" do
    test "changeset valid when input is lowercase" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true"})
      assert changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "false"})
      assert changeset.valid?
    end

    test "changeset valid when input is uppercase" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "TRUE"})
      assert changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "FALSE"})
      assert changeset.valid?
    end

    test "changeset valid when input is mixed-rcase" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "TRue"})
      assert changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "faLSE"})
      assert changeset.valid?
    end

    test "changeset fails when input is a number" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "1"})
      refute changeset.valid?
    end

    test "changeset fails when input is a string" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "random"})
      refute changeset.valid?
    end

    test "changeset fails when input has extra space in between" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "TR UE"})
      refute changeset.valid?
    end

    test "changeset fails when boolean value is a subset of the input" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "1FALSE"})
      refute changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true1"})
      refute changeset.valid?
    end

    test "changeset fails when input has space seperated values" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "1 TRue"})
      refute changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true 1"})
      refute changeset.valid?

      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true false"})
      refute changeset.valid?
    end

    test "changeset fails when has input has trailing space" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "faLSE "})
      refute changeset.valid?
    end

    test "changeset fails when has input has starting space" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: " faLSE"})
      refute changeset.valid?
    end

    test "changeset fails when input has comma seperated values" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true,faLSE"})
      refute changeset.valid?
    end
  end

  describe "changeset for list type" do
    test "with normal list value" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@list_valid_attrs | value: "value1, value2"})
      assert changeset.valid?
    end

    test "valid changeset when input is not empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@list_valid_attrs | value: "random"})
      assert changeset.valid?
    end

    test "valid changeset when input can be interpreted as integer" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@list_valid_attrs | value: "112, value2"})
      assert changeset.valid?
    end

    test "valid changeset when input can be interpreted as boolean" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@list_valid_attrs | value: "value1, true"})
      assert changeset.valid?
    end

    test "changeset fails when input is empty" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: ""})
      refute changeset.valid?
    end
  end

  describe "changeset for utc_datetime type" do
    test "compete timestamp is valid" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@utc_datetime_valid_attrs | value: "2017-08-15T09:07:59.935703Z"})
      assert changeset.valid?
    end

    test "timestamp without timezone is valid" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@utc_datetime_valid_attrs | value: "2017-08-15T09:07:59.935703"})
      assert changeset.valid?
    end

    test "only date is invalid" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@utc_datetime_valid_attrs | value: "2017-08-15"})
      refute changeset.valid?
    end

    test "only time is invalid" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@utc_datetime_valid_attrs | value: "09:07:59.935703"})
      refute changeset.valid?
    end

    test "empty is invalid" do
      changeset = SystemVariable.changeset(%SystemVariable{}, %{@utc_datetime_valid_attrs | value: ""})
      refute changeset.valid?
    end
  end
end
