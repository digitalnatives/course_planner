defmodule CoursePlanner.Settings.SystemVariable do
  @moduledoc """
  This module holds the model for one system variable
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.{Changeset, Type}

  schema "system_variables" do
    field :key,      :string
    field :value,    :string
    field :type,     :string
    field :visible,  :boolean
    field :editable, :boolean
    field :required, :boolean
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    target_params =
      [
       :key,
       :value,
       :type,
       :visible,
       :editable,
       :required
      ]

    struct
    |> cast(params, target_params)
    |> validate_by_record_required(target_params)
    |> validate_value_type()
  end

  def changeset(struct, params, :user_update) do
    target_params =
      [
       :value,
       :type
      ]

    struct
    |> cast(params, target_params)
    |> validate_by_record_required(target_params)
    |> validate_value_type()
    |> validate_editable()
  end

  def validate_by_record_required(changeset, target_params) do
    required = changeset |> Changeset.get_field(:required)

    if required do
      validate_required(changeset, target_params)
    else
      changeset
    end
  end

  defp validate_editable(%{valid?: true} = changeset) do
    editable = changeset |> Changeset.get_field(:editable)

    if editable do
      changeset
    else
      add_error(changeset, :value, "operation is forbidden")
    end
  end
  defp validate_editable(changeset), do: changeset

  defp validate_value_type(%{valid?: true} = changeset) do
    value = changeset |> Changeset.get_field(:value)
    type  = changeset |> Changeset.get_field(:type)

    validation_result = parse_value(value, type)

    case validation_result do
      {:ok, _} -> changeset
      {:error, message} -> add_error(changeset, :value, message)
    end
  end
  defp validate_value_type(changeset), do: changeset

  def parse_value(value, "text"), do:         {:ok, value}
  def parse_value(value, "url"), do:          parse_url(value)
  def parse_value(value, "list"), do:         parse_list(value)
  def parse_value(value, "string"), do:       parse_string(value)
  def parse_value(value, "integer"), do:      parse_integer(value)
  def parse_value(value, "boolean"), do:      parse_boolean(value)
  def parse_value(value, "utc_datetime"), do: parse_utc_datetime(value)
  def parse_value(value, "timezone"), do:     parse_timezone(value)
  def parse_value(_value, _type), do:         {:error, "unknown type"}

  def parse_string(value) do
    if String.length(value || "") > 255 do
     {:error, "The given value is too long. Maximum 255 characters are allowed"}
    else
     {:ok, value}
    end
  end

  def parse_url(value) do
    uri = URI.parse(value || "")
    case uri do
      %URI{host: nil, scheme: nil, path: nil} -> {:ok, nil}
      %URI{scheme: nil} -> {:error, "Url should start with http:// or https://"}
      %URI{host: nil} -> {:error, "The given URL is not valid"}
      uri -> {:ok, uri}
    end
  end

  def parse_list(value) do
    parse_list =
      value
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    {:ok, parse_list}
  end

  def parse_integer(value) do
    case Integer.parse(value) do
      {parsed_value, ""} -> validate_number_range_inclusive(parsed_value, 0, 1_000_000)
      _                  -> {:error, "the given value should be a number"}
    end
  end

  defp validate_number_range_inclusive(number, min, max) do
    if number in (min..max) do
      {:ok, number}
    else
      {:error, "the given value should be between #{min} and #{max}"}
    end
  end

  defp parse_boolean(value) do
    case String.downcase(value) do
      "true"  -> {:ok, true}
      "false" -> {:ok, false}
      _       -> {:error, "the given value should be true or false"}
    end
  end

  def parse_utc_datetime(value) do
    case Type.cast(:utc_datetime, value) do
      :error -> {:error, "is not an ISO8601 datetime"}
      {:ok, _} = result -> result
    end
  end

  def parse_timezone(value) do
    if value in Timex.timezones() do
      {:ok, value}
    else
      {:error, "the timezone #{value} is not valid."}
    end
  end
end
