defmodule CoursePlanner.UserController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias CoursePlanner.Router.Helpers
  alias Coherence.ControllerHelpers
  alias Ecto.DateTime
  require Logger

  def index(conn, _params) do
    query = from u in User, where: is_nil(u.deleted_at)
    users = Repo.all(query)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user} = params) do
    email = user["email"]
    token = ControllerHelpers.random_string 48
    url = Helpers.password_url(conn, :edit, token)
    reset_params =
      %{"reset_password_token" => token,
        "reset_password_sent_at" => DateTime.utc,
        "password" => "fakepassword"}
    merged = Map.merge(user, reset_params)
    user = User.changeset(%User{}, merged, :create)
    case Repo.insert(user) do
      {:ok, user} ->
        ControllerHelpers.send_user_email :password, user, url
        conn
        |> put_flash(:info, "User created and notified by.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} -> Logger.warn("something went wrong creating a new user: #{changeset}")
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user,
      %{deleted_at: Ecto.DateTime.utc()},
      :delete)

    IO.inspect changeset
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: user_path(conn, :index))
    end
  end
end
