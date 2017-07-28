{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(CoursePlanner.Repo, :manual)

Code.compiler_options(ignore_module_conflict: true)
Code.require_file("test/support/test_notifier.ex")
