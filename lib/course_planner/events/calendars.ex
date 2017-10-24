defmodule CoursePlanner.Events.Calendars do
  @moduledoc """
  This module provides helper functions to populate the json for the calendar view
  """
  import Ecto.Query

  alias CoursePlanner.{
    Events.Event,
    Repo,
  }
  alias Ecto.Changeset

  def get_user_events(user, true, week_range) do
    case user.role do
     "Coordinator" -> get_all_events(week_range)
     _             -> get_user_events(user.id, week_range)
    end
  end
  def get_user_events(_user, false, week_range) do
      get_all_events(week_range)
  end

  def get_user_events(user_id, week_range) do
    query = from e in Event,
      join: u in assoc(e, :users),
      preload: [users: u],
      where: ^user_id == u.id and
        e.date >= ^week_range.beginning_of_week and e.date <= ^week_range.end_of_week

    Repo.all(query)
  end

  def get_all_events(week_range) do
    query = from e in Event,
      where: e.date >= ^week_range.beginning_of_week and e.date <= ^week_range.end_of_week

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
    types = %{date: :date, my_events: :boolean}

    {data, types}
    |> Changeset.cast(params, Map.keys(types))
  end

  def format_errors(changeset_errors) do
    errors =
      Enum.reduce(changeset_errors, %{}, fn({error_field, {error_message, _}}, out) ->
        Map.put(out, error_field, error_message)
      end)

    %{errors: errors}
  end
end
