defmodule CoursePlanner.AboutControllerTest do
  use CoursePlannerWeb.ConnCase

  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    conn =
      role
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  defp populate_settings(program_data) do
    Enum.reduce(program_data, %{}, fn(data, out) ->
      system_variable = insert(:system_variable, data)

      Map.put(out, system_variable.key, %{value: system_variable.value, type: system_variable.type})
    end)
  end

  @tag user_role: :coordinator
  test "shows chosen resource", %{conn: conn} do
    program_data =
    [
      %{
        key: "PROGRAM_WEBSITE_URL",
        value: "http://www.program-website-url.com/",
        type: "url"
       },
      %{
        key: "ATTENDANCE_DESCRIPTIONS",
        value: "sick leave, informed beforehand",
        type: "list"
       },
      %{
        key: "PROGRAM_DESCRIPTION",
        value: "some sample description of the program",
        type: "text"
       },
      %{
         key: "PROGRAM_NAME",
         value: "some name",
         type: "string"
       }
    ]

    populated_settings = populate_settings(program_data)

    conn = get conn, about_path(conn, :show)
    assert html_response(conn, 200) =~ "About #{populated_settings["PROGRAM_NAME"].value}"
  end
end
