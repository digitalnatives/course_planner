defmodule CoursePlanner.Teachers do
  @moduledoc false
  alias CoursePlanner.Repo
  alias CoursePlanner.User
  import Ecto.Query

  @teachers from u in User, where: u.role == "Teacher" and is_nil(u.deleted_at)

  def all do
    Repo.all(@teachers)
  end
end
