defmodule CoursePlanner.Factory do
@moduledoc """
  provides factory function for tests 
"""
  alias CoursePlanner.{Course, OfferedCourse, Repo, Students, Class}
  alias CoursePlanner.Terms.Term

  @valid_class_attrs %{offered_course_id: nil, date: %{day: 17, month: 4, year: 2010},
                       finishes_at: %{hour: 14, min: 0, sec: 0},
                       starting_at: %{hour: 14, min: 0, sec: 0}, status: "Planned"}

  def create_term(name, start_date, end_date, course) do
     Repo.insert!(
       %Term{
         name: name,
         start_date: start_date,
         end_date: end_date,
         courses: [course],
         status: "Planned"
       })
   end

 def create_course(name) do
   Repo.insert!(
     Course.changeset(
       %Course{},
       %{
         name: name,
         description: "Description",
         number_of_sessions: 1,
         session_duration: "01:00:00",
         status: "Active"
       }))
 end

 def create_offered_course(term, course, students) do
   Repo.insert!(
     %OfferedCourse
     {
       term_id: term.id,
       course_id: course.id,
       students: students
     }
   )
 end

 def create_student(name, email) do
    {:ok, student} = Students.new(%{name: name, email: email}, "whatever")
    student
 end

 def create_class(offered_course) do
    Repo.insert!(Class.changeset(
      %Class{}, %{@valid_class_attrs | offered_course_id: offered_course.id}))
 end
end
