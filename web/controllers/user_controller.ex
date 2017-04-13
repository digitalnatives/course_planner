defmodule CoursePlanner.UserController do
  use CoursePlanner.Web, :controller
  alias CoursePlanner.User
  alias Coherence.Invitation

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Invitation.changeset(%Invitation{})
    conn
    |> put_view(Coherence.InvitationView)
    |> render("new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

end
