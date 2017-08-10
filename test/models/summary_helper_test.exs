defmodule CoursePlanner.SummaryHelperTest do
  use CoursePlanner.ModelCase

  import CoursePlanner.Factory
  alias CoursePlanner.SummaryHelper

  @empty_summary_helper_user_data_response %{terms: [], offered_courses: []}

  test "when user role is unknown" do
    student = insert(:student)
    [term1, term2] = insert_list(2, :term)
    insert_list(4, :offered_course, term: term1)
    insert(:offered_course, term: term2, students: [student])

    student_data = SummaryHelper.get_term_offered_course_for_user(%{student | role: "Unknown"})
    assert student_data == @empty_summary_helper_user_data_response
  end

  describe "Student summary data" do
    test "when she does not exist" do
      student = build(:student, id: -1)
      student_data = SummaryHelper.get_term_offered_course_for_user(student)
      assert student_data == @empty_summary_helper_user_data_response
    end

    test "when she is not registered to any offered_course" do
      student = insert(:student)
      insert(:class)

      student_data = SummaryHelper.get_term_offered_course_for_user(student)
      assert student_data == @empty_summary_helper_user_data_response
    end

    test "when she has a course in one term" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term)

      insert_list(4, :offered_course, term: term1)
      offered_course =
        insert(:offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_data = SummaryHelper.get_term_offered_course_for_user(student)
      assert student_data == %{terms: [term2], offered_courses: [offered_course]}
    end

    test "when she has multiple courses in one term" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term)

      insert_list(2, :offered_course, term: term1)
      offered_courses =
        insert_list(2, :offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_data = SummaryHelper.get_term_offered_course_for_user(student)
      assert student_data == %{terms: [term2], offered_courses: offered_courses}
    end

    test "when she has multiple courses in multiple terms" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term)

      offered_courses1 =
        insert_list(2, :offered_course, term: term1, students: [student])
        |> Repo.preload(:classes)

      offered_courses2 =
        insert_list(2, :offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_data = SummaryHelper.get_term_offered_course_for_user(student)

      student_data_sorted_terms = Enum.sort(student_data.terms, &(&1.id >= &2.id))
      student_data_sorted_offered_courses = Enum.sort(student_data.offered_courses, &(&1.id >= &2.id))

      expected_data_terms = Enum.sort([term1, term2], &(&1.id >= &2.id))
      expected_data_offered_courses = Enum.sort(offered_courses1 ++ offered_courses2, &(&1.id >= &2.id))

      assert student_data_sorted_terms == expected_data_terms
      assert student_data_sorted_offered_courses == expected_data_offered_courses
    end

    test "when she has multiple courses the end_date of all terms are passed" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term, end_date: Timex.shift(Timex.now(), days: -2))

      insert_list(2, :offered_course, term: term1, students: [student])
      insert_list(2, :offered_course, term: term2, students: [student])

      assert SummaryHelper.get_term_offered_course_for_user(student) == @empty_summary_helper_user_data_response
    end

    test "when she has multiple courses excluding the term that is finished and its data" do
      student = insert(:student)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)

      insert_list(2, :offered_course, term: term1, students: [student])
      offered_courses2 =
        insert_list(2, :offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_data = SummaryHelper.get_term_offered_course_for_user(student)
      assert student_data == %{terms: [term2], offered_courses: offered_courses2}
    end

    test "has no task" do
      volunteers = insert_list(2, :volunteer)
      student = insert(:student)
      insert(:task, volunteers: volunteers)

      next_task = SummaryHelper.get_next_task(student, Timex.now())

      assert next_task == nil
    end
  end

  describe "Teacher summary data" do
    test "when she does not exist" do
      teacher = build(:teacher, id: -1)
      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher)
      assert teacher_data == @empty_summary_helper_user_data_response
    end

    test "when she is not registered to any offered_course" do
      teacher = insert(:teacher)
      insert(:class)

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher)
      assert teacher_data == @empty_summary_helper_user_data_response
    end

    test "when she has a course in one term" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term)

      insert_list(4, :offered_course, term: term1)
      offered_course =
        insert(:offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher)
      assert teacher_data == %{terms: [term2], offered_courses: [offered_course]}
    end

    test "when she has multiple courses in one term" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term)

      insert_list(2, :offered_course, term: term1)
      offered_courses =
        insert_list(2, :offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher)
      assert teacher_data == %{terms: [term2], offered_courses: offered_courses}
    end

    test "when she has multiple courses in multiple terms" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term)

      offered_courses1 =
        insert_list(2, :offered_course, term: term1, teachers: [teacher])
        |> Repo.preload(:classes)

      offered_courses2 =
        insert_list(2, :offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher)
      assert teacher_data == %{terms: [term1, term2], offered_courses: offered_courses1 ++ offered_courses2}
    end

    test "when she has multiple courses excluding the term that is finished and its data" do
      teacher = insert(:teacher)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)

      insert_list(2, :offered_course, term: term1, teachers: [teacher])
      offered_courses2 =
        insert_list(2, :offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher)
      assert teacher_data == %{terms: [term2], offered_courses: offered_courses2}
    end

    test "when she has multiple courses the end_date of all terms are passed" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term, end_date: Timex.shift(Timex.now(), days: -2))

      insert_list(2, :offered_course, term: term1, teachers: [teacher])
      insert_list(2, :offered_course, term: term2, teachers: [teacher])

      assert SummaryHelper.get_term_offered_course_for_user(teacher) == @empty_summary_helper_user_data_response
    end

    test "has no task" do
      volunteers = insert_list(2, :volunteer)
      teacher = insert(:teacher)
      insert(:task, volunteers: volunteers)

      next_task = SummaryHelper.get_next_task(teacher, Timex.now())

      assert next_task == nil
    end
  end

  describe "Coordinator summary data" do
    test "when there is no term" do
      coordinator = build(:coordinator, id: -1)
      summary_data = SummaryHelper.get_term_offered_course_for_user(coordinator)

      assert summary_data == @empty_summary_helper_user_data_response
    end

    test "when there are terms but no offered_course" do
      coordinator = insert(:coordinator)
      terms = insert_list(2, :term)
      summary_data = SummaryHelper.get_term_offered_course_for_user(coordinator)

      assert summary_data == %{terms: terms, offered_courses: []}
    end

    test "when only one term has offered_course" do
      coordinator = insert(:coordinator)
      [term1, term2] = insert_list(2, :term)
      term2_offered_course =
        insert(:offered_course, term: term2)
        |> Repo.preload(:classes)

      summary_data = SummaryHelper.get_term_offered_course_for_user(coordinator)
      assert summary_data == %{terms: [term1, term2], offered_courses: [term2_offered_course]}
    end

    test "when each term has offered_courses" do
      coordinator = insert(:coordinator)
      [term1, term2] = insert_list(2, :term)
      term1_offered_course =
        insert(:offered_course, term: term1)
        |> Repo.preload(:classes)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses([term1_offered_course | term2_offered_courses])
      summary_data = SummaryHelper.get_term_offered_course_for_user(coordinator)

      assert summary_data == %{terms: [term1, term2], offered_courses: expected_offered_courses}
    end

    test "when term end time is past all it's data will be excluded" do
      coordinator = insert(:coordinator)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)
      insert(:offered_course, term: term1)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses(term2_offered_courses)
      summary_data = SummaryHelper.get_term_offered_course_for_user(coordinator)

      assert summary_data == %{terms: [term2], offered_courses: expected_offered_courses}
    end

    test "no data returns when every term's end date is passed" do
      coordinator = insert(:coordinator)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -10))
      term2 = insert(:term, end_date: Timex.shift(Timex.now(), days: -20))
      insert_list(6, :offered_course, term: term1)
      insert_list(4, :offered_course, term: term2)

      assert SummaryHelper.get_term_offered_course_for_user(coordinator) == @empty_summary_helper_user_data_response
    end

    test "has no task" do
      volunteers = insert_list(2, :volunteer)
      coordinator = insert(:coordinator)
      insert(:task, volunteers: volunteers)

      next_task = SummaryHelper.get_next_task(coordinator, Timex.now())

      assert next_task == nil
    end
  end

  describe "Volunteer summary data" do
    test "when there is no term" do
      volunteer = build(:volunteer, id: -1)
      summary_data = SummaryHelper.get_term_offered_course_for_user(volunteer)

      assert summary_data == @empty_summary_helper_user_data_response
    end

    test "when there are terms but no offered_course" do
      volunteer = insert(:volunteer)
      terms = insert_list(2, :term)
      summary_data = SummaryHelper.get_term_offered_course_for_user(volunteer)

      assert summary_data == %{terms: terms, offered_courses: []}
    end

    test "when only one term has offered_course" do
      volunteer = insert(:volunteer)
      [term1, term2] = insert_list(2, :term)
      term2_offered_course =
        insert(:offered_course, term: term2)
        |> Repo.preload(:classes)

      summary_data = SummaryHelper.get_term_offered_course_for_user(volunteer)

      assert summary_data == %{terms: [term1, term2], offered_courses: [term2_offered_course]}
    end

    test "when each term has offered_courses" do
      volunteer = insert(:volunteer)
      [term1, term2] = insert_list(2, :term)
      term1_offered_course =
        insert(:offered_course, term: term1)
        |> Repo.preload(:classes)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses([term1_offered_course | term2_offered_courses])
      summary_data = SummaryHelper.get_term_offered_course_for_user(volunteer)

      assert summary_data == %{terms: [term1, term2], offered_courses: expected_offered_courses}
    end

    test "when term end time is past all it's data will be excluded" do
      volunteer = insert(:volunteer)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)
      insert(:offered_course, term: term1)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses(term2_offered_courses)
      summary_data = SummaryHelper.get_term_offered_course_for_user(volunteer)

      assert summary_data == %{terms: [term2], offered_courses: expected_offered_courses}
    end

    test "no data returns when every term's end date is passed" do
      volunteer = insert(:volunteer)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -10))
      term2 = insert(:term, end_date: Timex.shift(Timex.now(), days: -20))
      insert_list(6, :offered_course, term: term1)
      insert_list(4, :offered_course, term: term2)

      assert SummaryHelper.get_term_offered_course_for_user(volunteer) == @empty_summary_helper_user_data_response
    end

    test "next task is nil when user does not exist" do
      next_task = SummaryHelper.get_next_task(%{id: -1, role: "Volunteer"}, Timex.now())

      assert next_task == nil
    end

    test "when she has one upcoming task" do
      [volunteer1, volunteer2] = insert_list(2, :volunteer)
      task = insert(:task,
                    start_time: Timex.shift(Timex.now(), days: 2),
                    finish_time: Timex.shift(Timex.now(), days: 3),
                    volunteers: [volunteer1, volunteer2])
      next_task = SummaryHelper.get_next_task(volunteer1, Timex.now())

      assert next_task.id == task.id
    end

    test "when she has many upcoming task the closest will return" do
      [volunteer1, volunteer2, volunteer3] = insert_list(3, :volunteer)
      task = insert(:task,
                    start_time: Timex.shift(Timex.now(), days: 2),
                    finish_time: Timex.shift(Timex.now(), days: 3),
                    volunteers: [volunteer1, volunteer2])
      insert(:task,
             start_time: Timex.shift(Timex.now(), days: 3),
             finish_time: Timex.shift(Timex.now(), days: 3),
             volunteers: [volunteer1, volunteer3])
      insert(:task,
             start_time: Timex.shift(Timex.now(), days: 1),
             finish_time: Timex.shift(Timex.now(), days: 1),
             volunteers: [volunteer2, volunteer3])
      next_task = SummaryHelper.get_next_task(volunteer1, Timex.now())

      assert next_task.id == task.id
    end

    test "when all tasks assigned to her have already started or finished" do
      [volunteer1, volunteer2, volunteer3] = insert_list(3, :volunteer)
      insert(:task,
             start_time: Timex.shift(Timex.now(), days: -2),
             finish_time: Timex.shift(Timex.now(), days: -1),
             volunteers: [volunteer1, volunteer2])
      insert(:task,
             start_time: Timex.shift(Timex.now(), days: -1),
             finish_time: Timex.shift(Timex.now(), days: 1),
             volunteers: [volunteer1, volunteer3])
      insert(:task,
             start_time: Timex.shift(Timex.now(), days: 1),
             finish_time: Timex.shift(Timex.now(), days: 2),
             volunteers: [volunteer2, volunteer3])
      next_task = SummaryHelper.get_next_task(volunteer1, Timex.now())

      assert next_task == nil
    end
  end

  describe "get_next_class function" do
    test "when offered_course is an empty list" do
      next_class = SummaryHelper.get_next_class([])

      assert next_class == nil
    end

    test "when offered_course is not a list" do
      next_class = SummaryHelper.get_next_class(nil)

      assert next_class == nil
    end

    test "when offered_course have no class" do
      offered_courses = insert_list(4, :offered_course) |> Repo.preload(:classes)
      next_class = SummaryHelper.get_next_class(offered_courses)

      assert next_class == nil
    end

    test "when offered_courses have classes on the same date with different hours" do
      [offered_course1, offered_course2] = insert_list(2, :offered_course)
      insert(:class, offered_course: offered_course1, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: 2))
      class = insert(:class, offered_course: offered_course1, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: 1))
      insert(:class, offered_course: offered_course2, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: 3))
      insert(:class, offered_course: offered_course2, date: Timex.now(), starting_at: Timex.shift(Timex.now(), hours: 4))

      preload_offered_courses = preload_associations_for_offered_courses([offered_course1, offered_course2])
      next_class = SummaryHelper.get_next_class(preload_offered_courses) |> Repo.preload([offered_course: [:course, :term]])

      assert next_class == class
    end

    test "when offered_courses have classes on the same time with different date" do
      [offered_course1, offered_course2] = insert_list(2, :offered_course)
      insert(:class, offered_course: offered_course1, starting_at: Timex.now(), date: Timex.shift(Timex.now(), days: 2))
      insert(:class, offered_course: offered_course1, starting_at: Timex.now(), date: Timex.shift(Timex.now(), days: 3))
      class = insert(:class, offered_course: offered_course2, starting_at: Timex.now(), date: Timex.shift(Timex.now(), days: 1))
      insert(:class, offered_course: offered_course2, starting_at: Timex.now(), date: Timex.shift(Timex.now(), days: 4))

      preload_offered_courses = preload_associations_for_offered_courses([offered_course1, offered_course2])
      next_class = SummaryHelper.get_next_class(preload_offered_courses) |> Repo.preload([offered_course: [:course, :term]])

      assert next_class == class
    end
  end

  defp preload_associations_for_offered_courses(offered_courses) do
    offered_courses
    |> Enum.map(fn(offered_course) ->
         Repo.preload(offered_course, [:classes])
       end)
  end
end
