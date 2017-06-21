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

  test "changeset for valid string system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: "random"})
    assert changeset.valid?
  end

  test "changeset for invalid string system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | value: ""})
    refute changeset.valid?
  end

  test "changeset for valid integer system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "0"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1000"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1000000"})
    assert changeset.valid?
  end

  test "changeset for out of boundary integer system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "-1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1000001"})
    refute changeset.valid?
  end

  test "changeset for integer system variable with invalid input" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1.1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1ab"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "ab1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1 1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@integer_valid_attrs | value: "1_000_000"})
    refute changeset.valid?
  end

  test "changeset for valid boolean system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "false"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "TRUE"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "FALSE"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "TRue"})
    assert changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "faLSE"})
    assert changeset.valid?
  end

  test "changeset for boolean system variable with invalid input" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "random"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "TR UE"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "1FALSE"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "1 TRue"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true 1"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "faLSE "})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: " faLSE"})
    refute changeset.valid?

    changeset = SystemVariable.changeset(%SystemVariable{}, %{@boolean_valid_attrs | value: "true,faLSE"})
    refute changeset.valid?
  end

  test "changeset fails for uneditable system variable" do
    changeset = SystemVariable.changeset(%SystemVariable{}, %{@string_valid_attrs | editable: false}, :update)
    refute changeset.valid?
  end
end
