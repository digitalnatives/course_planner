defmodule CoursePlanner.Factory do
@moduledoc """
  provides factory function for tests
"""
alias CoursePlanner.Terms.Term
alias CoursePlanner.{User, Course, OfferedCourse, Class}

  use ExMachina.Ecto, repo: CoursePlanner.Repo

 def user_factory do
   %User{
     name: sequence(:name, &"user-#{&1}"),
     email: sequence(:email, &"user-#{&1}@courseplanner.com"),
     status: "Active",
   }
 end

 def term_factory do
   %Term{
     name: sequence(:name, &"term-#{&1}"),
     status: "Planned"
   }
 end

 def course_factory do
  %Course{
     name: sequence(:name, &"course-#{&1}"),
     description: "Description",
     number_of_sessions: 1,
     session_duration: "01:00:00",
     status: "Planned"
  }
 end

 def offered_course_factory do
   %OfferedCourse{
   }
 end

 def class_factory do
    %Class{
      status: "Planned"
    }
 end
end
