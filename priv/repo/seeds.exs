CoursePlanner.Repo.delete_all CoursePlanner.SystemVariable
CoursePlanner.Repo.delete_all CoursePlanner.User

x = %CoursePlanner.User{}
|> CoursePlanner.User.changeset(
    %{
      name: "v1",
      family_name: "vv1",
      email: "vvv1@example.com",
      password: "secret",
      password_confirmation: "secret",
      role: "Volunteer"
    },
    :seed)
|> CoursePlanner.Repo.insert!

y = %CoursePlanner.User{}
|> CoursePlanner.User.changeset(
    %{
      name: "v2",
      family_name: "vv2",
      email: "vvv2@example.com",
      password: "secret",
      password_confirmation: "secret",
      role: "Volunteer"
    },
    :seed)
|> CoursePlanner.Repo.insert!

w= %CoursePlanner.User{}
|> CoursePlanner.User.changeset(
    %{
      name: "v3",
      family_name: "vv3",
      email: "vvv3@example.com",
      password: "secret",
      password_confirmation: "secret",
      role: "Volunteer"
    },
    :seed)
|> CoursePlanner.Repo.insert!


t =   %CoursePlanner.Tasks.Task{}
|> CoursePlanner.Tasks.Task.changeset(
    %{
      name: "task1",
      max_volunteer: "3",
      start_time: ~N[2017-07-19 13:28:19.756767] ,
      finish_time: ~N[2017-07-19 14:28:19.756767],
      description: "sample desc",
    })
|> Ecto.Changeset.put_assoc(:users, [x, y, w])
|> CoursePlanner.Repo.insert!

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
      key: "PROGRAM_NAME",
      value: "some name",
      type: "string",
      editable: true,
      visible: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_ADDRESS",
      value: "some address",
      type: "string",
      editable: true,
      visible: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "PROGRAM_EMAIL",
      value: "some email",
      type: "string",
      editable: true,
      visible: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "NOTIFICATION_FREQUENCY",
      value: "1",
      type: "integer",
      editable: true,
      visible: true
    })
|> CoursePlanner.Repo.insert!

%CoursePlanner.SystemVariable{}
|> CoursePlanner.SystemVariable.changeset(
    %{
      key: "ATTENDANCE_DESCRIPTIONS",
      value: "sick leave, informed beforehand",
      type: "list",
      editable: true,
      visible: true
    })
|> CoursePlanner.Repo.insert!
