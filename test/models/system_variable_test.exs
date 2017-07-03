defmodule CoursePlanner.SystemVariableTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.SystemVariable

  @string_valid_attrs %{key: "sample key", value: "sample value", type: "string", visible: true, editable: true}
  @integer_valid_attrs %{key: "sample key", value: "1", type: "integer", visible: true, editable: true}
  @boolean_valid_attrs %{key: "sample key", value: "true", type: "boolean", visible: true, editable: true}
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
end
