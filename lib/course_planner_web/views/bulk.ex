defmodule CoursePlannerWeb.BulkView do
  @moduledoc false
  use CoursePlannerWeb, :view

  def get_csv_field(target) do
    case target do
      "user" -> ["name*", "family name*", "nickname", "email*", "role*"]
    end
  end
end
