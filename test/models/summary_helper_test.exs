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

    student_data = SummaryHelper.get_term_offered_course_for_user(student.id, "Unknown")
    assert student_data == @empty_summary_helper_user_data_response
  end

  describe "Student summary data" do
    test "when she does not exist" do
      student_data = SummaryHelper.get_term_offered_course_for_user(-1, "Student")
      assert student_data == @empty_summary_helper_user_data_response
    end

    test "when she is not registered to any offered_course" do
      student = insert(:student)
      insert(:class)

      student_data = SummaryHelper.get_term_offered_course_for_user(student.id, student.role)
      assert student_data == @empty_summary_helper_user_data_response
    end

    test "when she has a course in one term" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term)

      insert_list(4, :offered_course, term: term1)
      offered_course =
        insert(:offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: [offered_course]}

      student_data = SummaryHelper.get_term_offered_course_for_user(student.id, student.role)
      assert student_data == student_summary_data_response
    end

    test "when she has multiple courses in one term" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term)

      insert_list(2, :offered_course, term: term1)
      offered_courses =
        insert_list(2, :offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: offered_courses}

      student_data = SummaryHelper.get_term_offered_course_for_user(student.id, student.role)
      assert student_data == student_summary_data_response
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

      student_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term1, term2], offered_courses: offered_courses1 ++ offered_courses2}

      student_data = SummaryHelper.get_term_offered_course_for_user(student.id, student.role)
      assert student_data == student_summary_data_response
    end

    test "when she has multiple courses the end_date of all terms are passed" do
      student = insert(:student)
      [term1, term2] = insert_list(2, :term, end_date: Timex.shift(Timex.now(), days: -2))

      insert_list(2, :offered_course, term: term1, students: [student])
      insert_list(2, :offered_course, term: term2, students: [student])

      assert SummaryHelper.get_term_offered_course_for_user(student.id, student.role) == @empty_summary_helper_user_data_response
    end

    test "when she has multiple courses excluding the term that is finished and its data" do
      student = insert(:student)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)

      insert_list(2, :offered_course, term: term1, students: [student])
      offered_courses2 =
        insert_list(2, :offered_course, term: term2, students: [student])
        |> Repo.preload(:classes)

      student_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: offered_courses2}

      student_data = SummaryHelper.get_term_offered_course_for_user(student.id, student.role)
      assert student_data == student_summary_data_response
    end
  end

  describe "Teacher summary data" do
    test "when she does not exist" do
      teacher_data = SummaryHelper.get_term_offered_course_for_user(-1, "Teacher")
      assert teacher_data == @empty_summary_helper_user_data_response
    end

    test "when she is not registered to any offered_course" do
      teacher = insert(:teacher)
      insert(:class)

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher.id, teacher.role)
      assert teacher_data == @empty_summary_helper_user_data_response
    end

    test "when she has a course in one term" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term)

      insert_list(4, :offered_course, term: term1)
      offered_course =
        insert(:offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: [offered_course]}

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher.id, teacher.role)
      assert teacher_data == teacher_summary_data_response
    end

    test "when she has multiple courses in one term" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term)

      insert_list(2, :offered_course, term: term1)
      offered_courses =
        insert_list(2, :offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: offered_courses}

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher.id, teacher.role)
      assert teacher_data == teacher_summary_data_response
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

      teacher_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term1, term2], offered_courses: offered_courses1 ++ offered_courses2}

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher.id, teacher.role)
      assert teacher_data == teacher_summary_data_response
    end

    test "when she has multiple courses excluding the term that is finished and its data" do
      teacher = insert(:teacher)
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)

      insert_list(2, :offered_course, term: term1, teachers: [teacher])
      offered_courses2 =
        insert_list(2, :offered_course, term: term2, teachers: [teacher])
        |> Repo.preload(:classes)

      teacher_summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: offered_courses2}

      teacher_data = SummaryHelper.get_term_offered_course_for_user(teacher.id, teacher.role)
      assert teacher_data == teacher_summary_data_response
    end

    test "when she has multiple courses the end_date of all terms are passed" do
      teacher = insert(:teacher)
      [term1, term2] = insert_list(2, :term, end_date: Timex.shift(Timex.now(), days: -2))

      insert_list(2, :offered_course, term: term1, teachers: [teacher])
      insert_list(2, :offered_course, term: term2, teachers: [teacher])

      assert SummaryHelper.get_term_offered_course_for_user(teacher.id, teacher.role) == @empty_summary_helper_user_data_response
    end
  end

  describe "Coordinator summary data" do
    test "when there is no term" do
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator")

      assert summary_data == @empty_summary_helper_user_data_response
    end

    test "when there are terms but no offered_course" do
      terms = insert_list(2, :term)
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator")

      assert summary_data == %{@empty_summary_helper_user_data_response | terms: terms}
    end

    test "when only one term has offered_course" do
      [term1, term2] = insert_list(2, :term)
      term2_offered_course =
        insert(:offered_course, term: term2)
        |> Repo.preload(:classes)

      summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term1, term2], offered_courses: [term2_offered_course]}
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator")

      assert summary_data == summary_data_response
    end

    test "when each term has offered_courses" do
      [term1, term2] = insert_list(2, :term)
      term1_offered_course =
        insert(:offered_course, term: term1)
        |> Repo.preload(:classes)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses([term1_offered_course | term2_offered_courses])
      summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term1, term2], offered_courses: expected_offered_courses}
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator")

      assert summary_data == summary_data_response
    end

    test "when term end time is past all it's data will be excluded" do
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)
      insert(:offered_course, term: term1)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses(term2_offered_courses)
      summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: expected_offered_courses}
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator")

      assert summary_data == summary_data_response
    end

    test "no data returns when every term's end date is passed" do
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -10))
      term2 = insert(:term, end_date: Timex.shift(Timex.now(), days: -20))
      insert_list(6, :offered_course, term: term1)
      insert_list(4, :offered_course, term: term2)

      assert SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator") == @empty_summary_helper_user_data_response
    end
  end

  describe "Volunteer summary data" do
    test "when there is no term" do
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Volunteer")

      assert summary_data == @empty_summary_helper_user_data_response
    end

    test "when there are terms but no offered_course" do
      terms = insert_list(2, :term)
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Volunteer")

      assert summary_data == %{@empty_summary_helper_user_data_response | terms: terms}
    end

    test "when only one term has offered_course" do
      [term1, term2] = insert_list(2, :term)
      term2_offered_course =
        insert(:offered_course, term: term2)
        |> Repo.preload(:classes)

      summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term1, term2], offered_courses: [term2_offered_course]}
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Volunteer")

      assert summary_data == summary_data_response
    end

    test "when each term has offered_courses" do
      [term1, term2] = insert_list(2, :term)
      term1_offered_course =
        insert(:offered_course, term: term1)
        |> Repo.preload(:classes)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses([term1_offered_course | term2_offered_courses])
      summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term1, term2], offered_courses: expected_offered_courses}
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Volunteer")

      assert summary_data == summary_data_response
    end

    test "when term end time is past all it's data will be excluded" do
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -2))
      term2 = insert(:term)
      insert(:offered_course, term: term1)
      term2_offered_courses = insert_list(4, :offered_course, term: term2)

      expected_offered_courses = preload_associations_for_offered_courses(term2_offered_courses)
      summary_data_response =
        %{@empty_summary_helper_user_data_response | terms: [term2], offered_courses: expected_offered_courses}
      summary_data = SummaryHelper.get_term_offered_course_for_user(-1, "Volunteer")

      assert summary_data == summary_data_response
    end

    test "no data returns when every term's end date is passed" do
      term1 = insert(:term, end_date: Timex.shift(Timex.now(), days: -10))
      term2 = insert(:term, end_date: Timex.shift(Timex.now(), days: -20))
      insert_list(6, :offered_course, term: term1)
      insert_list(4, :offered_course, term: term2)

      assert SummaryHelper.get_term_offered_course_for_user(-1, "Coordinator") == @empty_summary_helper_user_data_response
    end
  end

  defp preload_associations_for_offered_courses(offered_courses) do
    offered_courses
    |> Enum.map(fn(offered_course) ->
         Repo.preload(offered_course, [:classes])
       end)
  end
end
