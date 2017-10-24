defmodule CoursePlanner.CurrentUserTest do
  use ExUnit.Case

  alias CoursePlanner.CurrentUser

  test "init/1" do
    param = ["random", "param"]
    assert CurrentUser.init(param) == param
  end
end
