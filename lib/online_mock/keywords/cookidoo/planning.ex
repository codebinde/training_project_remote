defmodule OnlineMock.Keywords.Cookidoo.Planning do
  @moduledoc false

  use RemoteLibrary

  @keyword "Remove Planned Recipe From My Week For Day"
  @keyword_args %{day: {nil, nil}, recipe_id: {nil, nil}}
  @keyword_doc """
  Removes a planned recipe from my week for a given day

  - ``day`` - (YYYY-MM-DD) date of the recipe to remove.
  - ``recipe_id`` - id of the recipe to remove

  *Example*
  | _Remove Planned Recipe From My Week For Day_ | 2021-03-24 | recipe_01 |
  """
  @spec remove_planned_recipe_from_my_week(String.t(), String.t()) :: :ok
  def remove_planned_recipe_from_my_week(day, recipe_id) do
    OnlineMock.Data.PlannedRecipes.remove(day, recipe_id)

    :ok
  end

  @keyword "Append Planned Recipe To My Week For Day"
  @keyword_args %{locale: {"en", nil}}
  @keyword_doc """
  Adds a planned recipe to my week for a given day.

  - ``day`` - (YYYY-MM-DD) date the recipe will be planned for.
  - ``recipe_id`` - id of the recipe
  - ``locale`` - locale of the recipe

  *Example*
  | _Append Planned Recipe To My Week For Day_ | 2021-03-24 | recipe_01 | de |
  """
  @spec append_planned_recipe_to_my_week(String.t(), String.t(), String.t()) :: :ok
  def append_planned_recipe_to_my_week(day, recipe_id, locale) do
    OnlineMock.Data.PlannedRecipes.append(day, recipe_id, locale)

    :ok
  end
end
