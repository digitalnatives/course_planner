  defmodule CoursePlanner.Notification do
  @moduledoc """
    Schema for persisting email notification to send later
  """
  use CoursePlannerWeb, :model

  schema "notifications" do
    field :type, :string
    field :resource_path, :string, default: "/"
    field :data, :map, default: %{}
    belongs_to :user, CoursePlanner.User

    timestamps()
  end

  @types ~w(user_modified course_updated course_deleted
           term_updated term_deleted class_subscribed
           class_updated class_deleted)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :resource_path, :data])
    |> validate_required([:type])
    |> validate_inclusion(:type, @types)
    |> cast_assoc(:user)
    |> assoc_constraint(:user)
  end
end
