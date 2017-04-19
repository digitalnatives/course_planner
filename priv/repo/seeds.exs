CoursePlanner.Repo.delete_all CoursePlanner.User

CoursePlanner.User.changeset(%CoursePlanner.User{},
  %{first_name: "first",
    family_name: "family",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret"})
|> CoursePlanner.Repo.insert!
