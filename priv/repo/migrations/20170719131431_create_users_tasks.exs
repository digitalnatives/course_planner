defmodule CoursePlanner.Repo.Migrations.CreateUsersTasks do
  use Ecto.Migration

  def change do
    create table(:users_tasks, primary_key: false) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
    create index(:users_tasks, [:task_id])
    create index(:users_tasks, [:user_id])

    execute "CREATE OR REPLACE FUNCTION enforce_max_volunteer() RETURNS trigger AS $$
    DECLARE
      max_volunteer_for_task INTEGER := 0;
      current_volunteer_count INTEGER := 0;
    BEGIN
      LOCK TABLE tasks IN EXCLUSIVE MODE;

      SELECT max_volunteer INTO max_volunteer_for_task FROM tasks WHERE NEW.task_id = id;
      SELECT COUNT(*) INTO current_volunteer_count FROM  users_tasks WHERE NEW.task_id = task_id;

      IF current_volunteer_count + 1 > max_volunteer_for_task THEN
          RAISE EXCEPTION 'Max volunteer for this task is reached';
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;"

    execute "CREATE TRIGGER task_grap_update
      BEFORE INSERT OR UPDATE ON users_tasks
      FOR EACH ROW EXECUTE PROCEDURE enforce_max_volunteer()"
  end
end
