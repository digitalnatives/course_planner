defmodule CoursePlanner.TaskView do
  @moduledoc false
  use CoursePlanner.Web, :view

  def task_user(conn, task) do
    if task.user_id do
      link task.user.name, to: volunteer_path(conn, :show, task.user)
    else
      "no one"
    end
  end

  def format_users(users) do
    [{"no one", 0} | Enum.map(users, &{&1.name, &1.id})]
  end

  def page_title do
    "Tasks"
  end
end
