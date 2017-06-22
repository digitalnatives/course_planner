defmodule CoursePlanner.OfferedCourseController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.{ClassHelper, OfferedCourse, Students, Teachers}
  alias Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  import Canary.Plugs
  plug :authorize_controller

  def index(conn, _params) do
    offered_courses =
      OfferedCourse
      |> Repo.all()
      |> Repo.preload([:term, :course])
    render(conn, "index.html", offered_courses: offered_courses)
  end

  def new(conn, _params) do
    changeset = OfferedCourse.changeset(%OfferedCourse{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"offered_course" => offered_course_params}) do
    changeset = OfferedCourse.changeset(%OfferedCourse{}, offered_course_params)

    student_ids = Map.get(offered_course_params, "student_ids", [])
    students = Repo.all(from s in Students.query(), where: s.id in ^student_ids)
    changeset = Changeset.put_assoc(changeset, :students, students)

    teacher_ids = Map.get(offered_course_params, "teacher_ids", [])
    teachers = Repo.all(from s in Teachers.query(), where: s.id in ^teacher_ids)
    changeset = Changeset.put_assoc(changeset, :teachers, teachers)

    case Repo.insert(changeset) do
      {:ok, _offered_course} ->
        conn
        |> put_flash(:info, "Offered course created successfully.")
        |> redirect(to: offered_course_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%{assigns: %{current_user: %{role: user_role}}} = conn, %{"id" => id})
  when user_role in ["Coordinator", "Teacher"] do
    offered_course =
      OfferedCourse
      |> Repo.get!(id)
      |> Repo.preload([:term, :course, :students, :teachers, :classes])

    {past_classes, next_classes} =
      offered_course.classes
      |> ClassHelper.sort_by_starting_time()
      |> ClassHelper.split_past_and_next()

    render(conn, "show.html", offered_course: offered_course,
                              next_classes: next_classes,
                              past_classes: past_classes,
                              user_role: user_role)
  end

  def show(%{assigns: %{current_user: %{role: user_role, id: user_id}}} = conn, %{"id" => id})
  when user_role == "Student" do
    offered_course =
      OfferedCourse
      |> Repo.get!(id)
      |> Repo.preload([:term, :course, :students, :teachers])

    {past_classes, next_classes} =
      id
      |> ClassHelper.classes_with_attendances(user_id)
      |> ClassHelper.split_past_and_next()

    render(conn, "show.html", offered_course: offered_course,
                              next_classes: next_classes,
                              past_classes: past_classes,
                              user_role: user_role)
  end

  def edit(conn, %{"id" => id}) do
    offered_course =
      OfferedCourse
      |> Repo.get!(id)
      |> Repo.preload([:term, :course, :students, :teachers])
    changeset = OfferedCourse.changeset(offered_course)
    render(conn, "edit.html", offered_course: offered_course, changeset: changeset)
  end

  def update(conn, %{"id" => id, "offered_course" => offered_course_params}) do
    offered_course =
      OfferedCourse
      |> Repo.get!(id)
      |> Repo.preload([:term, :course, :students, :teachers])
    changeset = OfferedCourse.changeset(offered_course, offered_course_params)

    student_ids = Map.get(offered_course_params, "student_ids", [])
    students = Repo.all(from s in Students.query(), where: s.id in ^student_ids)
    changeset = Changeset.put_assoc(changeset, :students, students)

    teacher_ids = Map.get(offered_course_params, "teacher_ids", [])
    teachers = Repo.all(from s in Teachers.query(), where: s.id in ^teacher_ids)
    changeset = Changeset.put_assoc(changeset, :teachers, teachers)

    case Repo.update(changeset) do
      {:ok, offered_course} ->
        conn
        |> put_flash(:info, "Offered course updated successfully.")
        |> redirect(to: offered_course_path(conn, :show, offered_course))
      {:error, changeset} ->
        render(conn, "edit.html", offered_course: offered_course, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    offered_course = Repo.get!(OfferedCourse, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(offered_course)

    conn
    |> put_flash(:info, "Offered course deleted successfully.")
    |> redirect(to: offered_course_path(conn, :index))
  end
end
