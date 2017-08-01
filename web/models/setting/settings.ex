defmodule CoursePlanner.Settings do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, SystemVariable}
  alias Ecto.Multi

  schema "settings_fake_table" do
    embeds_many :system_variables, SystemVariable
  end

  def wrap(system_variables) do
    %__MODULE__{}
    |> cast(%{}, [])
    |> put_embed(:system_variables, system_variables)
  end

  @all_query               from sv in SystemVariable, select: {sv.id, sv}, order_by: :key
  @visible_settings_query  from sv in SystemVariable, where: sv.visible, order_by: :key
  @editable_settings_query from sv in SystemVariable, where: sv.editable, order_by: :key

  def all do
    Repo.all(@all_query)
  end

  def get_value(name, default \\ nil) do
    system_variable = Repo.get_by(SystemVariable, key: name)

    {:ok, parsed_value} =
      case system_variable do
        nil -> {:ok, default}
        _   -> SystemVariable.parse_value(system_variable.value, system_variable.type)
      end

    parsed_value
  end

  def filter_non_program_systemvariables(settings) do
    Enum.reject(settings, &(String.starts_with?(&1.key, "PROGRAM")))
  end

  def filter_program_systemvariables(settings) do
    Enum.reject(settings, &(not String.starts_with?(&1.key, "PROGRAM")))
  end

  def get_visible_systemvariables do
    Repo.all(@visible_settings_query)
  end

  def get_editable_systemvariables do
    Repo.all(@editable_settings_query)
  end

  def get_changesets_for_update(param_variables) do
    system_variables = all() |> Enum.into(Map.new)
    Enum.map(param_variables, &update_changeset(system_variables, &1))
  end

  defp update_changeset(system_variables, new_value) do
    {_pos, %{"id" => param_id, "value" => param_value}} = new_value
    {param_id, ""} = Integer.parse(param_id)
    found_system_variable = Map.get(system_variables, param_id)

    cond do
      is_nil(found_system_variable) -> :non_existing_resource
      not found_system_variable.editable -> :uneditable_resource
      found_system_variable.editable ->
        SystemVariable.changeset(found_system_variable, %{"value" => param_value}, :update)
    end
  end

  def update(changesets) do
    changesets
    |> Enum.reduce(Multi.new, &add_update_changeset/2)
    |> Repo.transaction()
  end

  defp add_update_changeset(:non_existing_resource, multi) do
    Multi.error(multi, :non_existing_resource, "Resource does not exist")
  end
  defp add_update_changeset(:uneditable_resource, multi) do
    Multi.error(multi, :uneditable_resource, "Resource is not editable")
  end
  defp add_update_changeset(changeset, multi) do
    name = changeset.data.id |> Integer.to_string |> String.to_atom
    Multi.update(multi, name, changeset)
  end
end
