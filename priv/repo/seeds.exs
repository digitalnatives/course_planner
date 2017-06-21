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
    key: "Program name",
    value: "some name",
    type: "string",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "Program address",
    value: "some address",
    type: "string",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "Program email",
    value: "some email",
    type: "string",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!

CoursePlanner.SystemVariable.changeset(%CoursePlanner.SystemVariable{},
  %{
    key: "Notification frequency",
    value: "1",
    type: "integer",
    editable: true,
    visible: true})
|> CoursePlanner.Repo.insert!
