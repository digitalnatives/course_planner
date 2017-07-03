CoursePlanner.Repo.delete_all CoursePlanner.SystemVariable
CoursePlanner.Repo.delete_all CoursePlanner.User

CoursePlanner.User.changeset(%CoursePlanner.User{},
  %{name: "first",
    family_name: "family",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Coordinator"},
    :seed)
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "PROGRAM_NAME",
    value: "some name",
    type: "string",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "PROGRAM_ADDRESS",
    value: "some address",
    type: "string",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "PROGRAM_EMAIL",
    value: "some email",
    type: "string",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "NOTIFICATION_FREQUENCY",
    value: "1",
    type: "integer",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!
