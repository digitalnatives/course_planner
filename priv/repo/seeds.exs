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

CoursePlanner.User.changeset(%CoursePlanner.User{},
  %{name: "Coordinator",
    family_name: "Test",
    email: "coordinator@example.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Coordinator"},
    :seed)
|> CoursePlanner.Repo.insert!

CoursePlanner.User.changeset(%CoursePlanner.User{},
  %{name: "Student",
    family_name: "Test",
    email: "student@example.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Student"},
    :seed)
|> CoursePlanner.Repo.insert!

CoursePlanner.User.changeset(%CoursePlanner.User{},
  %{name: "Teacher",
    family_name: "Test",
    email: "teacher@example.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Teacher"},
    :seed)
|> CoursePlanner.Repo.insert!

CoursePlanner.User.changeset(%CoursePlanner.User{},
  %{name: "Volunteer",
    family_name: "Test",
    email: "volunteer@example.com",
    password: "secret",
    password_confirmation: "secret",
    role: "Volunteer"},
    :seed)
|> CoursePlanner.Repo.insert!
