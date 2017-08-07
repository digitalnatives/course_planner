defmodule CoursePlanner.LayoutViewTest do
  use CoursePlanner.ConnCase, async: true

  alias CoursePlanner.LayoutView
  import CoursePlanner.Factory

  test "get_program_name returns PROGRAM_NAME system_variable value" do
    sys_var_key = "PROGRAM_NAME"
    sys_var_value = "sample_program_name"
    insert(:system_variable, %{key: sys_var_key, type: "string", value: sys_var_value})

    assert LayoutView.get_program_name() == sys_var_value
  end

  test "show_program_about? returns SHOW_PROGRAM_ABOUT_PAGE system_variable value" do
    sys_var_key = "SHOW_PROGRAM_ABOUT_PAGE"
    sys_var_value = "false"
    insert(:system_variable, %{key: sys_var_key, type: "string", value: sys_var_value})

    assert LayoutView.show_program_about?() == sys_var_value
  end
end
