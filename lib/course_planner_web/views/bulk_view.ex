defmodule CoursePlannerWeb.BulkView do
  @moduledoc false
  use CoursePlannerWeb, :view

  def get_csv_fields(target) do
    required_fields =
      case target do
        "user" -> ["name*", "family name*", "nickname", "email*", "role*"]
        _      -> []
      end

    Enum.join(required_fields, ",")
  end
end
