defmodule CoursePlanner.TermsTest do
  use CoursePlanner.ModelCase

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
end
