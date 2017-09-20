defmodule CoursePlanner.TermsTest do
  use CoursePlannerWeb.ModelCase

  alias CoursePlanner.Terms
  import CoursePlanner.Factory

  test "should return the subscribed users of terms" do
    term = insert(:term)
    insert(:coordinator)
    students = insert_list(3, :student)
    teachers = insert_list(2, :teacher)
    insert(:offered_course, term: term, students: students, teachers: teachers)
    insert(:offered_course, term: term, students: students, teachers: teachers)

    term_users = Terms.get_subscribed_users(term)
    assert length(term_users) == 6
  end


  describe "find_all_by_user/1" do
    test "coordinators should see all offered courses" do
      user = insert(:coordinator)
      term = insert(:term)
      insert_list(2, :offered_course, term: term)

      terms = Terms.find_all_by_user(user)
      assert length(terms) == 1

      term = List.first(terms)
      assert length(term.offered_courses) == 2
    end

    test "teachers should see the offered courses they are assigned to" do
      user = insert(:teacher)
      term = insert(:term)
      user_course = insert(:offered_course, term: term, teachers: [user])
      insert(:offered_course, term: term)

      terms = Terms.find_all_by_user(user)
      assert length(terms) == 1

      term = List.first(terms)
      assert List.first(term.offered_courses).id == user_course.id
    end

    test "students should see the offered courses they are assigned to" do
      user = insert(:student)
      user_course = insert(:offered_course, students: [user])
      insert(:offered_course)

      terms = Terms.find_all_by_user(user)
      assert length(terms) == 1

      term = List.first(terms)
      assert List.first(term.offered_courses).id == user_course.id
    end
  end
end
