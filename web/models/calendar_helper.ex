defmodule CoursePlanner.CalenderHelper do
  @moduledoc """
  This module provides helper functions to populate the json for the calendar view
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, OfferedCourse}
  alias Ecto.Changeset

  def get_user_classes(user, true, week_range) do
    case user.role do
     "Student"     -> get_student_classes(user.id, week_range)
     "Teacher"     -> get_teacher_classes(user.id, week_range)
     _             -> get_all_classes(week_range)
    end
  end

  def get_user_classes(_user, false, week_range) do
      get_all_classes(week_range)
  end

  def get_student_classes(user_id, week_range) do
    query = from oc in OfferedCourse,
    join: s in assoc(oc, :students),
    join: c in assoc(oc, :classes),
    preload: [:term, :course, :teachers, classes: c],
    where: ^user_id in s.id and
      c.date >= ^week_range.beginning_of_week and c.date <= ^week_range.end_of_week

    Repo.all(query)
  end

  def get_teacher_classes(user_id, week_range) do
    query = from oc in OfferedCourse,
    join: t in assoc(oc, :teachers),
    join: c in assoc(oc, :classes),
    preload: [:term, :course, :teachers, classes: c],
    where: ^user_id == t.id and
      c.date >= ^week_range.beginning_of_week and c.date <= ^week_range.end_of_week

    Repo.all(query)
  end

  def get_all_classes(week_range) do
    query = from oc in OfferedCourse,
    join: c in assoc(oc, :classes),
    preload: [:term, :course, :teachers, classes: c],
    where: c.date >= ^week_range.beginning_of_week and c.date <= ^week_range.end_of_week

    Repo.all(query)
  end

  def get_week_range(date) do
    %{
      beginning_of_week: Timex.beginning_of_week(date),
      end_of_week: Timex.end_of_week(date)
     }
  end

  def validate(params) do
    data  = %{}
    types = %{date: :date, my_classes: :boolean}

    {data, types}
    |> Changeset.cast(params, Map.keys(types))
  end
end
