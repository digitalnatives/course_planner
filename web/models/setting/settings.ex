defmodule CoursePlanner.Settings do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, SystemVariable}
  alias Ecto.Multi

  @visible_settings_query from sv in SystemVariable, where: sv.visible == true, order_by: :key
  @editable_settings_query from sv in SystemVariable, where: sv.editable == true, order_by: :key

  def get_visible_systemvariables do
    Repo.all(@visible_settings_query)
  end

  def get_editable_systemvariables do
    Repo.all(@editable_settings_query)
  end

  def update(changesets) do
    multi =
      Enum.reduce(changesets, Multi.new, fn(changeset, out_multi) ->
        operation_atom =
          changeset.data.id
          |> Integer.to_string()
          |> String.to_atom()

        Multi.update(out_multi, operation_atom, changeset)
      end)

    Repo.transaction(multi)
  end

  def insert_error(form, errors) do
    form =  Map.put form, :valid?, false
    Enum.reduce(errors, form, fn(error, out_form) ->
      add_error(out_form, error.field, error.message)
    end)
  end
end
