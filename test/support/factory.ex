defmodule CoursePlanner.Factory do
@moduledoc """
  provides factory function for tests
"""
alias CoursePlanner.Terms.{Term,Holiday}
alias CoursePlanner.{User, Course, OfferedCourse, Class, Attendance, Tasks.Task, SystemVariable, Notification}

  use ExMachina.Ecto, repo: CoursePlanner.Repo

  @password_hash CoursePlanner.User.encrypt_password("secret")

 def user_factory do
   %User{
     name: sequence(:name, &"user-#{&1}"),
     email: sequence(:email, &"user-#{&1}@courseplanner.com"),
     password_hash: @password_hash,
     notification_period_days: 1
   }
 end

 def student_factory do
   %User{
     name: sequence(:name, &"student-#{&1}"),
     email: sequence(:email, &"student-#{&1}@courseplanner.com"),
     role: "Student",
     password_hash: @password_hash,
     notification_period_days: 1
   }
 end

 def teacher_factory do
   %User{
     name: sequence(:name, &"teacher-#{&1}"),
     email: sequence(:email, &"teacher-#{&1}@courseplanner.com"),
     role: "Teacher",
     password_hash: @password_hash,
     notification_period_days: 1
   }
 end

 def coordinator_factory do
   %User{
     name: sequence(:name, &"coordinator-#{&1}"),
     email: sequence(:email, &"coordinator-#{&1}@courseplanner.com"),
     role: "Coordinator",
     password_hash: @password_hash,
     notification_period_days: 1
   }
 end

 def volunteer_factory do
   %User{
     name: sequence(:name, &"volunteer-#{&1}"),
     email: sequence(:email, &"volunteer-#{&1}@courseplanner.com"),
     role: "Volunteer",
     password_hash: @password_hash,
     notification_period_days: 1
   }
 end

 def term_factory do
   %Term{
     name: sequence(:name, &"term-#{&1}"),
     start_date: Timex.shift(Timex.now(), days: -10),
     end_date:   Timex.shift(Timex.now(), months: 1),
     minimum_teaching_days: 5
   }
 end

 def course_factory do
  %Course{
     name: sequence(:name, &"course-#{&1}"),
     description: "Description"
  }
 end

 def offered_course_factory do
   %OfferedCourse{
     term: build(:term),
     course: build(:course),
     number_of_sessions: 1,
     syllabus: "some content"
   }
 end

 def class_factory do
    %Class{
      offered_course: build(:offered_course)
    }
 end

 def attendance_factory do
    %Attendance{
      attendance_type: "Not filled"
    }
 end

 def task_factory do
   %Task{
     name: "some content",
     max_volunteers: 2,
     start_time: Timex.shift(Timex.now(), days: -5),
     finish_time: Timex.shift(Timex.now(), days: 2),
   }
 end

 def holiday_factory do
    %Holiday{
      date: %Ecto.Date{day: 1, month: 1, year: 2017},
      description: "some description"
    }
 end

 def system_variable_factory do
    %SystemVariable{
      key: sequence(:name, &"setting-#{&1}"),
      value: "some value",
      type: "string",
      visible: true,
      editable: true,
      required: true
    }
 end

 def notification_factory do
   %Notification{
    type: "user_modified",
    resource_path: "/"
   }
 end
end
