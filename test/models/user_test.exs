defmodule CoursePlanner.UserTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.User

  describe "required fields" do
    test "changeset is invalid without email" do
      changeset = User.changeset(%User{}, %{})
      assert changeset.errors[:email] == {"can't be blank", [validation: :required]}
    end
  end

  describe "email format" do
    test "changeset is invalid when email doesn't contain `@`" do
      changeset = User.changeset(%User{}, %{email: "not email"})
      assert changeset.errors[:email] == {"has invalid format", [validation: :format]}
    end

    test "changeset is valid when email contains `@`" do
      changeset = User.changeset(%User{}, %{email: "foo@bar.com"})
      refute changeset.errors[:email]
    end
  end

  describe "email uniqueness" do
    test "changeset can't be inserted when email already exists" do
      changeset = User.changeset(
        %User{},
        %{
          name: "foo",
          family_name: "bar",
          email: "foo@bar.com",
          password: "secret",
          password_confirmation: "secret"
          })
      assert {:ok, _} = Repo.insert(changeset)
      assert {:error, error_changeset} = Repo.insert(changeset)
      assert error_changeset.errors[:email] == {"has already been taken", []}
    end
  end

  describe "comments lentgh" do
    test "changeset is valid when comment is empty" do
      changeset = User.changeset(%User{}, %{comments: ""})
      refute changeset.errors[:comments]
    end

    test "changeset is valid when comment is 255 characters" do
      changeset = User.changeset(%User{}, %{comments: String.duplicate("a", 255)})
      refute changeset.errors[:comments]
    end

    test "changeset is invalid when comment is bigger than 255 characters" do
      changeset = User.changeset(%User{}, %{comments: String.duplicate("a", 256)})
      assert changeset.errors[:comments] == {"should be at most %{count} character(s)", [count: 255, validation: :length, max: 255]}
    end
  end
end
