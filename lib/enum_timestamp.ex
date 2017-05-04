defmodule EnumTimestamp do
  @moduledoc """
  Behaviour to represent Enum with mapping to timestamp
  """
  @callback valid_types() :: [String.t]
  @callback types_timestamp() :: [{String.t, atom()}]
end
