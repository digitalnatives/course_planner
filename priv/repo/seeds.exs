CoursePlanner.Repo.delete_all CoursePlanner.Setting
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

CoursePlanner.Setting.changeset(%CoursePlanner.Setting{},
  %{notification_frequency: 1,
    program_name: "Sample program name",
    program_description: "Sample program description",
    program_phone_number: "Sample phone number",
    program_email_address: "Sample email address",
    program_address: "sample address"})
|> CoursePlanner.Repo.insert!
