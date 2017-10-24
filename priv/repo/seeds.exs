alias CoursePlanner.{Accounts.User, Repo, Settings.SystemVariable}
import Ecto.Query

has_coordinators? = Repo.one(from u in User, where: u.role == "Coordinator", select: 1, limit: 1)
unless has_coordinators? do
  %User{} |> User.changeset(
      %{
        name: "first",
        family_name: "family",
        email: "testuser@example.com",
        password: "secret",
        password_confirmation: "secret",
        role: "Coordinator"
      },
      :seed) |> Repo.insert!
end

attendance_descriptions = Repo.get_by(SystemVariable, key: "ATTENDANCE_DESCRIPTIONS")
if attendance_descriptions do
  attendance_descriptions
  |> SystemVariable.changeset(
      %{
        type: "list",
        editable: true,
        visible: true,
        required: true
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "ATTENDANCE_DESCRIPTIONS",
        value: "sick leave, informed beforehand",
        type: "list",
        editable: true,
        visible: true,
        required: true
      }) |> Repo.insert!()
end

show_program_about_page = Repo.get_by(SystemVariable, key: "SHOW_PROGRAM_ABOUT_PAGE")
if show_program_about_page do
  show_program_about_page
  |> SystemVariable.changeset(
      %{
        type: "boolean",
        editable: true,
        visible: true,
        required: true
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "SHOW_PROGRAM_ABOUT_PAGE",
        value: "true",
        type: "boolean",
        editable: true,
        visible: true,
        required: true
      }) |> Repo.insert!()
end

program_name = Repo.get_by(SystemVariable, key: "PROGRAM_NAME")
if program_name do
  program_name
  |> SystemVariable.changeset(
      %{
        type: "string",
        editable: true,
        visible: true,
        required: true
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_NAME",
        value: "some name",
        type: "string",
        editable: true,
        visible: true,
        required: true
      }) |> Repo.insert!()
end

program_address = Repo.get_by(SystemVariable, key: "PROGRAM_ADDRESS")
if program_address do
  program_address
  |> SystemVariable.changeset(
      %{
        type: "text",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_ADDRESS",
        value: "some address",
        type: "text",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

program_email = Repo.get_by(SystemVariable, key: "PROGRAM_EMAIL")
if program_email do
  program_email
  |> SystemVariable.changeset(
      %{
        type: "text",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_EMAIL",
        value: "some email",
        type: "text",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

program_description = Repo.get_by(SystemVariable, key: "PROGRAM_DESCRIPTION")
if program_description do
  program_description
  |> SystemVariable.changeset(
      %{
        type: "text",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_DESCRIPTION",
        value: "some sample description of the program",
        type: "text",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

program_information = Repo.get_by(SystemVariable, key: "PROGRAM_INFORMATION")
if program_information do
  program_information
  |> SystemVariable.changeset(
      %{
        type: "text",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_INFORMATION",
        value: "our office is open from 11am until 6pm monday to friday",
        type: "text",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

program_logo_url = Repo.get_by(SystemVariable, key: "PROGRAM_LOGO_URL")
if program_logo_url do
  program_logo_url
  |> SystemVariable.changeset(
      %{
        type: "url",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_LOGO_URL",
        value: nil,
        type: "url",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

program_website_url = Repo.get_by(SystemVariable, key: "PROGRAM_WEBSITE_URL")
if program_website_url do
  program_website_url
  |> SystemVariable.changeset(
      %{
        type: "url",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_WEBSITE_URL",
        value: "http://www.program-website-url.com/",
        type: "url",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

program_phone = Repo.get_by(SystemVariable, key: "PROGRAM_PHONE")
if program_phone do
  program_phone
  |> SystemVariable.changeset(
      %{
        type: "text",
        editable: true,
        visible: true,
        required: false
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "PROGRAM_PHONE",
        value: "+0036 111 1111",
        type: "text",
        editable: true,
        visible: true,
        required: false
      }) |> Repo.insert!()
end

enable_notification = Repo.get_by(SystemVariable, key: "ENABLE_NOTIFICATION")
if enable_notification do
  enable_notification
  |> SystemVariable.changeset(
      %{
        type: "boolean",
        editable: true,
        visible: true,
        required: true
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "ENABLE_NOTIFICATION",
        value: "true",
        type: "boolean",
        editable: true,
        visible: true,
        required: true
      }) |> Repo.insert!()
end

notification_job_executed_at = Repo.get_by(SystemVariable, key: "NOTIFICATION_JOB_EXECUTED_AT")
if notification_job_executed_at do
  notification_job_executed_at
  |> SystemVariable.changeset(
      %{
        type: "utc_datetime",
        editable: false,
        visible: false,
        required: true
       })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "NOTIFICATION_JOB_EXECUTED_AT",
        value: DateTime.utc_now() |> DateTime.to_iso8601(),
        type: "utc_datetime",
        editable: false,
        visible: false,
        required: true
      }) |> Repo.insert!()
end

timezone = Repo.get_by(SystemVariable, key: "TIMEZONE")
if timezone do
  timezone
  |> SystemVariable.changeset(
      %{
        type: "timezone",
        editable: true,
        visible: true,
        required: true
      })
  |> Repo.update!()
else
  %SystemVariable{} |> SystemVariable.changeset(
      %{
        key: "TIMEZONE",
        value: "Europe/Budapest",
        type: "timezone",
        editable: true,
        visible: true,
        required: true
      }) |> Repo.insert!()
end

"Seed ran successfully."
