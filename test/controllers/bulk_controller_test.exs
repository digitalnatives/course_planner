defmodule CoursePlanner.BulkControllerTest do
  use CoursePlannerWeb.ConnCase

  alias CoursePlanner.{Repo, Accounts.User}

  import CoursePlanner.Factory

  setup(%{user_role: role}) do
    user = insert(role)

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  defp create_input_params(target, title, csv_data) do
    path = Plug.Upload.random_file!("csv")
    File.write!(path, csv_data)
    %{"input" => %{"csv_file" => %{"path" => path}, "target" => target, "title" => title}}
  end

  @moduletag user_role: :student
  describe "settings functionality for student user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 403)
    end

    test "does not create bulk request for student user", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 403)
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end

  @moduletag user_role: :teacher
  describe "settings functionality for teacher user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      html_response(conn, 403)
    end

    test "does not create bulk request for teacher user", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 403)
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end

  @moduletag user_role: :volunteer
  describe "settings functionality for volunteer user" do
    test "does not render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 403)
    end

    test "does not create bulk request for volunteer user", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 403)
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end

  @moduletag user_role: :coordinator
  describe "settings functionality for coordinator user" do
    test "render new page", %{conn: conn} do
      conn = get conn, bulk_path(conn, :new, target: "user", title: "Bulk Users")
      assert html_response(conn, 200) =~ "Bulk Users"
    end

    @tag user_role: :coordinator
    test "creates bulk request with one row of data", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert redirected_to(conn) == user_path(conn, :index)
      assert get_flash(conn, "info") == "All users are created and notified by"
      assert Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "creates bulk request with multiple rows of data", %{conn: conn} do
      params = create_input_params("user", "user bulk creation",
        """
           Aname,AFamile,Anickname,a@a.com,Student
           Bname,BFamile,Bnickname,b@b.com,Teacher
           Cname,CFamile,Cnickname,c@c.com,Volunteer
           Dname,DFamile,Dnickname,d@d.com,Coordinator
        """)
      conn = post conn, bulk_path(conn, :create, params)
      assert redirected_to(conn) == user_path(conn, :index)
      assert get_flash(conn, "info") == "All users are created and notified by"
      assert Repo.get_by(User, email: "a@a.com")
      assert Repo.get_by(User, email: "b@b.com")
      assert Repo.get_by(User, email: "c@c.com")
      assert Repo.get_by(User, email: "d@d.com")
    end

    test "does not create bulk request if input file is missing", %{conn: conn} do
      params = %{"input" => %{"target" => "user", "title" => "user bulk creation"}}
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200) =~ "You have to select a file"
    end

    test "does not create bulk request if input file is empty", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200) =~ "Input can not be empty"
    end

    test "does not create bulk request if input file is just new lines", %{conn: conn} do
      params = create_input_params("user", "user bulk creation",
        """



        """)
      conn = post conn, bulk_path(conn, :create, params)
      assert get_flash(conn, "error") == "Row has length 1 - expected length 5 on line 1"
    end

    test "does not create bulk request even if one of the lines is invalid when changeset fails", %{conn: conn} do
      params = create_input_params("user", "user bulk creation",
        """
          Aname,AFamile,Anickname,a@a.com,Student
          Bname,BFamile,Bnickname,b@b.com,Teacher
          Cname,CFamile,Cnickname,,Volunteer
          Dname,DFamile,Dnickname,d@d.com,Coordinator
        """)
      conn = post conn, bulk_path(conn, :create, params)
      assert get_flash(conn, "error") == "email can't be blank"
      refute Repo.get_by(User, email: "a@a.com")
      refute Repo.get_by(User, email: "b@b.com")
      refute Repo.get_by(User, email: "c@c.com")
      refute Repo.get_by(User, email: "d@d.com")
    end

    test "does not create bulk request even if one of the lines is invalid when csv fails", %{conn: conn} do
      params = create_input_params("user", "user bulk creation",
      """
         Aname,AFamile,Anickname,a@a.com,Student
         Bname,BFamile,Bnickname,b@b.com,Teacher
         Cname,CFamile,Cnickname,Volunteer
         Dname,DFamile,Dnickname,d@d.com,Coordinator
      """)
      conn = post conn, bulk_path(conn, :create, params)
      assert get_flash(conn, "error") == "Row has length 4 - expected length 5 on line 3"
      refute Repo.get_by(User, email: "a@a.com")
      refute Repo.get_by(User, email: "b@b.com")
      refute Repo.get_by(User, email: "c@c.com")
      refute Repo.get_by(User, email: "d@d.com")
    end

    test "does not create bulk request if input file does not have the correct format", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,,Anickname,a@a.com\nBname")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200) =~ "Row has length 1 - expected length 5 on line 2"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", email: "a@a.com", role: "Student")
    end

    test "does not create bulk request if input fields are not enough", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200) =~ "Row has length 4 - expected length 5 on line 1"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "does not create bulk request if role is unknown", %{conn: conn} do
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,unknown")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "role is invalid"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "does not create bulk request if email is already taken", %{conn: conn} do
      insert(:student, email: "a@a.com")
      params = create_input_params("user", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "email has already been taken"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end

    test "returning error if no action is implemented for the requested target", %{conn: conn} do
      params = create_input_params("invalid target", "user bulk creation", "Aname,AFamile,Anickname,a@a.com,Student")
      conn = post conn, bulk_path(conn, :create, params)
      assert html_response(conn, 200)
      assert get_flash(conn, "error") == "Something went wrong"
      refute Repo.get_by(User, name: "Aname", family_name: "AFamile", role: "Student")
    end
  end
end
