defmodule CoursePlanner.Settings do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, SystemVariable}
  alias Ecto.Multi

  @all_query               from SystemVariable, order_by: :key
  @visible_settings_query  from sv in SystemVariable, where: sv.visible  == true, order_by: :key
  @editable_settings_query from sv in SystemVariable, where: sv.editable == true, order_by: :key

  def all do
    Repo.all(@all_query)
  end

  def get_visible_systemvariables do
    Repo.all(@visible_settings_query)
  end

  def get_editable_systemvariables do
    Repo.all(@editable_settings_query)
  end

  def get_changesets_for_update(setting_params) do
    system_variables = all()

    Enum.map(setting_params, fn(setting_param) ->
      {param_id, param_value} = setting_param

      found_system_variable =
        Enum.find(system_variables, fn(system_variable) ->
          system_variable_id = to_string(system_variable.id)
          system_variable_id == param_id
        end)

        cond do
          is_nil(found_system_variable) -> :non_existing_resource
          not found_system_variable.editable -> :uneditable_resource
          found_system_variable.editable ->
            SystemVariable.changeset(found_system_variable, %{"value" => param_value}, :update)
        end
    end)
  end

  def update(changesets) do
    multi =
      Enum.reduce(changesets, Multi.new, fn(changeset, out_multi) ->

        case changeset do
           :non_existing_resource -> Multi.error(out_multi, :non_existing_resource, "Resource does not exist")
           :uneditable_resource   -> Multi.error(out_multi, :uneditable_resource, "Resource is not editable")
           _  ->
             operation_atom =
               changeset.data.id
               |> Integer.to_string()
               |> String.to_atom()
             Multi.update(out_multi, operation_atom, changeset)
        end
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
