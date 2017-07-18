defmodule CoursePlanner.TaskTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Tasks.Task
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  alias Ecto.Changeset

  import CoursePlanner.Factory

  @valid_attrs %{name: "mahname", start_time: Timex.now(), finish_time: Timex.now()}
  @invalid_attrs %{}

  defp create_task(user \\ nil) do
    Task.changeset(%Task{}, @valid_attrs)
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert!()
  end

  test "changeset with valid attributes" do
    volunteer = insert(:volunteer)
    changeset =
      create_task()
      |> Task.changeset(%{user: volunteer.id})
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = Task.changeset(%Task{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with no user_id" do
    changeset = Task.changeset(%Task{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no start_time" do
    changeset =
      create_task()
      |> Task.changeset(%{start_time: nil})
    refute changeset.valid?
  end

  test "changeset with no finish_time" do
    changeset =
      create_task()
      |> Task.changeset(%{finish_time: nil})
    refute changeset.valid?
  end

  test "query tasks per volunteer" do
    volunteer = insert(:volunteer)
    create_task(volunteer)
    create_task(volunteer)
    create_task(volunteer)
    user = Repo.one from u in User, preload: [:tasks]
    assert length(user.tasks) == 3
  end
end
