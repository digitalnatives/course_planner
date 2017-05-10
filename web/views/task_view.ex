defmodule CoursePlanner.TaskView do
  use CoursePlanner.Web, :view

  def task_user(conn, task) do
    if task.user_id do
      link task.user.name, to: volunteer_path(conn, :show, task.user)
    else
      "no one"
    end
  end

end
