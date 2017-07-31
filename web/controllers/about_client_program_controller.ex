defmodule CoursePlanner.AboutClientProgramController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Settings

  def show(conn, _param) do
    mapped_visible_settings =
      Settings.get_program_descriptor_systemvariables()
      |> Settings.to_map

    program_data =
      %{
          name: Map.get(mapped_visible_settings, "PROGRAM_NAME"),
          address: Map.get(mapped_visible_settings, "PROGRAM_ADDRESS"),
          email: Map.get(mapped_visible_settings, "PROGRAM_EMAIL"),
          phone: Map.get(mapped_visible_settings, "PROGRAM_PHONE"),
          logo: Map.get(mapped_visible_settings, "PROGRAM_LOGO_URL"),
          website: Map.get(mapped_visible_settings, "PROGRAM_WEBSITE_URL"),
          information: Map.get(mapped_visible_settings, "PROGRAM_INFORMATION"),
          description: Map.get(mapped_visible_settings, "PROGRAM_DESCRIPTION")
       }

    render(conn, "show.html", program_data: program_data)
  end
end
