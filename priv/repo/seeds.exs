CoursePlanner.Repo.delete_all CoursePlanner.SystemVariable
CoursePlanner.Repo.delete_all CoursePlanner.User

%CoursePlanner.User{}
|> CoursePlanner.User.changeset(
    %{
      name: "first",
      family_name: "family",
      email: "testuser@example.com",
      password: "secret",
      password_confirmation: "secret",
      role: "Coordinator"
    },
    :seed)
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "ATTENDANCE_DESCRIPTIONS",
      value: "sick leave, informed beforehand",
      type: "list",
      editable: true,
      visible: true,
      required: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "SHOW_PROGRAM_ABOUT_PAGE",
      value: "true",
      type: "boolean",
      editable: true,
      visible: true,
      required: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_NAME",
      value: "some name",
      type: "string",
      editable: true,
      visible: true,
      required: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_ADDRESS",
      value: "some address",
      type: "string",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_EMAIL",
      value: "some email",
      type: "string",
      editable: true,
      visible: false,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_DESCRIPTION",
      value: "some sample description of the program",
      type: "text",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_INFORMATION",
      value: "our office is open from 11am until 6pm monday to friday",
      type: "text",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_LOGO_URL",
      value: "http://www.sample.com/logo.jpg",
      type: "url",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_WEBSITE_URL",
      value: "http://www.program-website-url.com/",
      type: "url",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_PHONE",
      value: "+0036 111 1111",
      type: "string",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "DISABLE_NOTIFICATION",
      value: "true",
      type: "boolean",
      editable: true,
      visible: true,
      required: false
    })
|> CoursePlanner.Repo.insert!
