defmodule CoursePlannerWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias CoursePlanner.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import CoursePlannerWeb.Router.Helpers
      import CoursePlanner.Factory

      # The default endpoint for testing
      @endpoint CoursePlannerWeb.Endpoint

      def guardian_login_html(user, token \\ :token, opts \\ []) do
        Phoenix.ConnTest.build_conn
        |> Phoenix.ConnTest.bypass_through(CoursePlannerWeb.Router, [:browser, :with_session, :login_required, :protected_api])
        |> Phoenix.ConnTest.get("/")
        |> Map.update!(:state, fn (_) -> :set end)
        |> Guardian.Plug.sign_in(user, token, opts)
        |> Plug.Conn.send_resp(200, "Flush the session")
        |> Phoenix.ConnTest.recycle
        |> assign(:current_user, user)
      end

      def guardian_login_html_json(user, token \\ :token, opts \\ []) do
        { :ok, jwt, _ } = Guardian.encode_and_sign(user, :protected_api)

        conn =
        Phoenix.ConnTest.build_conn
        |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}")
        |> assign(:current_user, user)
      end

      def build_conn(context) do
        user = context
        |> Map.get(:user_role, :coordinator)
        |> insert()
        case Map.get(context, :pipeline, nil) do
          :protected_api -> guardian_login_html_json(user)
          :browser       -> guardian_login_html(user)
          _              -> Phoenix.ConnTest.build_conn
        end
      end

    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CoursePlanner.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CoursePlanner.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
