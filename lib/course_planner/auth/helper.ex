defmodule CoursePlanner.Auth.Helper do
  @moduledoc """
    provides helper functions used by or related to authentication
  """
  def get_random_token_with_length(token_length) do
    token_length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, token_length)
  end
end
