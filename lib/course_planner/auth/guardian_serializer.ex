defmodule CoursePlanner.Auth.GuardianSerializer do
  @moduledoc """
    Handles serialization for the resource of login
  """
  @behaviour Guardian.Serializer

  alias CoursePlanner.{Repo, Accounts.User}

  def for_token(%User{} = user), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end
