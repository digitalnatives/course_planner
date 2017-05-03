defmodule EnumTimestamp do
  @callback valid_types() :: [String.t]
  @callback types_timestamp() :: [{String.t, atom()}]
end
