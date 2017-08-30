alias CoursePlanner.{User, Repo, SystemVariable}
import Ecto.Query

has_coordinators? = Repo.one(from u in User, where: u.role == "Coordinator", select: 1, limit: 1)
unless has_coordinators? do
  %User{}
  |> User.changeset(
      %{
        name: "first",
        family_name: "family",
        email: "testuser@example.com",
        password: "secret",
        password_confirmation: "secret",
        role: "Coordinator"
      },
      :seed)
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "ATTENDANCE_DESCRIPTIONS") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "ATTENDANCE_DESCRIPTIONS",
        value: "sick leave, informed beforehand",
        type: "list",
        editable: true,
        visible: true,
        required: true
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "SHOW_PROGRAM_ABOUT_PAGE") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "SHOW_PROGRAM_ABOUT_PAGE",
        value: "true",
        type: "boolean",
        editable: true,
        visible: true,
        required: true
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_NAME") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_NAME",
        value: "some name",
        type: "string",
        editable: true,
        visible: true,
        required: true
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_ADDRESS") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_ADDRESS",
        value: "some address",
        type: "string",
        editable: true,
        visible: true,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_EMAIL") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_EMAIL",
        value: "some email",
        type: "string",
        editable: true,
        visible: false,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_DESCRIPTION") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_DESCRIPTION",
        value: "some sample description of the program",
        type: "text",
        editable: true,
        visible: true,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_INFORMATION") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_INFORMATION",
        value: "our office is open from 11am until 6pm monday to friday",
        type: "text",
        editable: true,
        visible: true,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_LOGO_URL") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_LOGO_URL",
        value: "",
        type: "url",
        editable: true,
        visible: true,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_WEBSITE_URL") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_WEBSITE_URL",
        value: "http://www.program-website-url.com/",
        type: "url",
        editable: true,
        visible: true,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "PROGRAM_PHONE") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "PROGRAM_PHONE",
        value: "+0036 111 1111",
        type: "string",
        editable: true,
        visible: true,
        required: false
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "ENABLE_NOTIFICATION") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "ENABLE_NOTIFICATION",
        value: "true",
        type: "boolean",
        editable: true,
        visible: true,
        required: true
      })
  |> Repo.insert!
end

unless Repo.get_by(SystemVariable, key: "NOTIFICATION_JOB_EXECUTED_AT") do
  %SystemVariable{}
  |> SystemVariable.changeset(
      %{
        key: "NOTIFICATION_JOB_EXECUTED_AT",
        value: DateTime.utc_now() |> DateTime.to_iso8601(),
        type: "utc_datetime",
        editable: true,
        visible: false,
        required: true
      })
  |> Repo.insert!
end
