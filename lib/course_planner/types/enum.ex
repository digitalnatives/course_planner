defmodule CoursePlanner.Enum do
  @moduledoc """
  Behaviour to represent Enum with mapping to timestamp
  """

  @callback valid_types :: [String.t]

  defmacro __using__(_) do
    quote do
      @behaviour Ecto.Type
      @behaviour CoursePlanner.Enum

      def cast(value) do
        if Enum.member?(valid_types(), value), do: {:ok, value}, else: :error
      end

      def load(value), do: {:ok, value}

      def dump(value) do
        if Enum.member?(valid_types(), value), do: {:ok, value}, else: :error
      end

      def types_timestamp do
        Enum.into(valid_types(), %{}, &({&1, :"#{String.downcase(&1)}_at"}))
      end
      defoverridable types_timestamp: 0
    end
  end
end
